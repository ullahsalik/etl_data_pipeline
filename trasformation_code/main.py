import datetime, json, psycopg2, boto3, os
from dateutil.relativedelta import relativedelta
import pandas as pd

# Fetch Input files for trasformation
input_files = ['customers.csv', 'products.csv', 'purchase_history.csv']
BATCH_FILES_PATH = str(os.environ['BATCH_FILES_PATH'])
session = boto3.Session()
s3 = session.resource('s3') 

rds_client = session.client('rds', region_name='us-east-1')
token = rds_client.generate_db_auth_token(DBHostname='dev-assignment-aurora-postgresql-v1.cluster-cchexaiioten.us-east-1.rds.amazonaws.com', Port=5432, DBUsername='iamuser', Region='us-east-1')

batch_file_bucket = s3.Bucket('dev-assignment-batch-files-v1')
for file_name in input_files:
    full_file_name = "{}/{}".format("data",file_name)
    try:
        batch_file_bucket.download_file(full_file_name, file_name)
    except Exception as e:
        print(e)

# Create DataFrames
purchase_history_df = pd.read_csv('purchase_history.csv', encoding= 'unicode_escape')
customers_df = pd.read_csv('customers.csv', encoding= 'unicode_escape')
products_df = pd.read_csv('products.csv', encoding= 'unicode_escape')
purchased_records = []

with pd.option_context('display.max_rows', None, 'display.max_columns', None):
    city_list = list(set(customers_df["city"].tolist()))
    for City in city_list:
        # Query the customer id for a city
        customers = customers_df.query( 'city == @City', inplace = False)
        Customer_ids = customers['customer_id'].to_list()
        for Customer_id in Customer_ids:
            purchase_record = {}
            purchase_record['city'] = City
            # Query the customer_id in purchase_history            
            purchase_history = purchase_history_df.query( 'customer_id == @Customer_id', inplace = False)
            print(purchase_history.to_json())
            if not purchase_history.empty:
                Product_id = purchase_history["product_id"].to_list()[0]
                purhase_history = purchase_history["purhase_history"].to_list()[0]
                last_order_date = purchase_history["last_order_date"].to_list()[0]
                last_order_date = datetime.datetime(int(last_order_date.split('-')[0]), int(last_order_date.split('-')[1]),1).date()
                current_date = datetime.datetime.now().date().replace(day=1)
                purchase_record['current_date'] = datetime.datetime.now().date().strftime("%Y-%m-%d")
            elif purchase_history.empty:
                continue
            print(Customer_id)
            # Query the product category
            product_details = products_df.query( 'product_id == @Product_id', inplace = False)
            if not product_details.empty:
                product_category = product_details["product_category"].to_list()[0]
                purchase_record['product_category'] = product_category
        
            # processing out items sold each month
            last_12m_purhase_history = {}
            purhase_history_str = str(purhase_history)
            chunks, chunk_size = len(purhase_history_str), len(purhase_history_str)//12
            purhase_history = [ purhase_history_str[i:i+chunk_size] for i in range(0, chunks, chunk_size) ]
            for i in purhase_history:
                last_12m_purhase_history[last_order_date] = i
                last_order_date = last_order_date - relativedelta(months=1)
            print(last_12m_purhase_history,'\n')
            

            # Calculate last 3, 6, 9, 12 months purhase_history
            
            for n in range(0, 12, 3):
                last_nm_purchased_items = 0
                
                for i in range(n+3):
                    try:
                        last_nm_purchased_items = last_nm_purchased_items + int(last_12m_purhase_history[current_date - relativedelta(months=i)])
                    except Exception as e:
                        pass
                if n == 0:
                    purchase_record['unit_sold_in_last_3_months_from_current_date'] = last_nm_purchased_items
                if n == 3:
                    purchase_record['unit_sold_in_last_6_months_from_current_date'] = last_nm_purchased_items
                if n == 6:
                    purchase_record['unit_sold_in_last_9_months_from_current_date'] = last_nm_purchased_items
                if n == 9:
                    purchase_record['unit_sold_in_last_12_months_from_current_date'] = last_nm_purchased_items
            
            purchased_records.append(purchase_record)
    print(json.dumps(purchased_records,indent=4))
        
    
    with psycopg2.connect(host='dev-assignment-aurora-postgresql-v1.cluster-cchexaiioten.us-east-1.rds.amazonaws.com', user='iamuser', password=token, database='test_db', sslrootcert='SSLCERTIFICATE') as conn:
        with conn.cursor() as cur:
            for record in purchased_records:
                try:
                    postgres_insert_query = """ INSERT INTO purchase_history (date, city, product_category, unit_sold_in_last_3_months_from_current_date, unit_sold_in_last_6_months_from_current_date, unit_sold_in_last_9_months_from_current_date, unit_sold_in_last_12_months_from_current_date) VALUES (%s,%s,%s,%s,%s,%s,%s)"""
                    record_to_insert = (record['current_date'], record['city'], record['product_category'], record['unit_sold_in_last_3_months_from_current_date'], record['unit_sold_in_last_6_months_from_current_date'], record['unit_sold_in_last_9_months_from_current_date'], record['unit_sold_in_last_12_months_from_current_date'])
                    cur.execute(postgres_insert_query, record_to_insert)
                except Exception as e:
                    postgres_update_query = """ Update purchase_history set unit_sold_in_last_3_months_from_current_date = %s, unit_sold_in_last_6_months_from_current_date = %s, unit_sold_in_last_9_months_from_current_date = %s, unit_sold_in_last_12_months_from_current_date = %s where city = %s and product_category = %s"""
                    cur.execute(postgres_update_query, (record['unit_sold_in_last_3_months_from_current_date'], record['unit_sold_in_last_6_months_from_current_date'], record['unit_sold_in_last_9_months_from_current_date'], record['unit_sold_in_last_12_months_from_current_date'], record['city'], record['product_category']))
                finally:
                    conn.commit()
                    # conn.close()
                    count = cur.rowcount
                    print(count, "Record inserted successfully into purchase_history table")