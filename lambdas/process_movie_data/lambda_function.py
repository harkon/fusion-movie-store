import os
import json
import boto3
import logging
import mysql.connector
from typing import Dict, Tuple, List
from rediscluster import RedisCluster


def connect_to_redis(host, port, password, startup_nodes=None):
    if startup_nodes:
        return RedisCluster(host=host, port=port, password=password, decode_responses=True, ssl=True, ssl_cert_reqs=None, skip_full_coverage_check=True)
    else:
        import redis
        return redis.StrictRedis(host=host, port=port, password=password, decode_responses=True)


def connect_to_db(user, password, host, db_name):
    try:
        # Establish a connection to the MySQL database
        return mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=db_name
        )
    except Exception as e:
        raise e


def parse_file_content(event: Dict) -> Tuple[Dict, str]:
    try:
        s3_client = boto3.client('s3')
        records = event.get('Records')

        if not records:
            logging.warning("No records found")
            raise Exception("No records found")

        record = records[0]
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        etag = record['s3']['object']['eTag']
        file_obj = s3_client.get_object(Bucket=bucket, Key=key)
        file_content = file_obj["Body"].read().decode('utf-8')

        return json.loads(file_content), etag
    except Exception as e:
        logging.error(f'Error parsing file content: {e}')
        raise


def insert_actors_and_genres(cursor: mysql.connector.cursor, data: Dict) -> Tuple[List[int], List[int]]:
    actor_names = data['cast']
    genre_names = data['genres']

    unique_actors = {name: None for name in actor_names}
    unique_genres = {name: None for name in genre_names}

    # Query existing actors to avoid duplicate inserts
    actor_names_placeholder = ', '.join(['%s'] * len(actor_names))
    query = f"SELECT actor_id, name FROM actors WHERE name IN ({actor_names_placeholder})"
    cursor.execute(query, actor_names)
    for actor_id, actor_name in cursor.fetchall():
        unique_actors[actor_name] = actor_id

    # Query existing genres to avoid duplicate inserts
    genre_names_placeholder = ', '.join(['%s'] * len(genre_names))
    query = f"SELECT genre_id, name FROM genres WHERE name IN ({genre_names_placeholder})"
    cursor.execute(query, genre_names)
    for genre_id, genre_name in cursor.fetchall():
        unique_genres[genre_name] = genre_id

    # Insert unique actors
    for actor_name in actor_names:
        if unique_actors[actor_name] is None:
            cursor.execute(
                "INSERT INTO actors (name) VALUES (%s)", (actor_name,))
            unique_actors[actor_name] = cursor.lastrowid

    # Insert unique genres
    for genre_name in genre_names:
        if unique_genres[genre_name] is None:
            cursor.execute(
                "INSERT INTO genres (name) VALUES (%s)", (genre_name,))
            unique_genres[genre_name] = cursor.lastrowid

    actor_ids = [unique_actors[name] for name in actor_names]
    genre_ids = [unique_genres[name] for name in genre_names]

    return actor_ids, genre_ids


def handler(event: Dict, context: Dict):
    # Connect to Redis
    redis_host = os.environ.get('REDIS_HOST')
    redis_port = os.environ.get('REDIS_PORT')
    redis_password = os.environ.get('REDIS_PASSWORD')
    startup_nodes = os.environ.get('STARTUP_NODES', None)
    cache = connect_to_redis(redis_host, redis_port,
                             redis_password, startup_nodes=startup_nodes)
    # Connect to MySQL
    user = os.environ.get('DB_USER')
    password = os.environ.get('DB_PASSWORD')
    host = os.environ.get('DB_HOST')
    db_name = os.environ.get('DB_NAME')
    db_connection = connect_to_db(user, password, host, db_name)
    cursor = db_connection.cursor()
    # Parse file content
    data, etag = parse_file_content(event)

    if cache.get(etag):
        print("File has already been processed")
        return

    try:
        cache.set(etag, 1)
    except Exception as ex:
        print(ex)

    try:
        db_connection.start_transaction()
        actor_ids, genre_ids = insert_actors_and_genres(cursor, data)

        title = data['title']
        year = data['year']
        href = data.get('href', None)
        extract = data.get('extract', None)
        thumbnail = data.get('thumbnail', None)
        thumbnail_width = data.get('thumbnail_width', None)
        thumbnail_height = data.get('thumbnail_height', None)

        cursor.execute("""
            INSERT INTO movies (title, year, href, extract, thumbnail, thumbnail_width, thumbnail_height)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
                       (title, year, href, extract, thumbnail, thumbnail_width, thumbnail_height))

        movie_id = cursor.lastrowid
        # Link movie with actors
        for actor_id in actor_ids:
            cursor.execute("""
                INSERT INTO movies_actors (movie_id, actor_id)
                VALUES (%s, %s)
                """, (movie_id, actor_id))
            actor_id = cursor.lastrowid

        # Link movie with genres
        for genre_id in genre_ids:
            cursor.execute("""
                INSERT INTO movies_genres (movie_id, genre_id)
                VALUES (%s, %s)
                """, (movie_id, genre_id))
            genre_id = cursor.lastrowid

        db_connection.commit()
    except Exception as e:
        db_connection.rollback()
        cache.delete(etag)
        print(f'Error processing event: {e}')
        raise e
    finally:
        cursor.close()
        db_connection.close()
        cache.close()


if __name__ == '__main__':
    event = {
        "Records": [
            {
                "s3": {
                    "bucket": {
                        "name": "incoming-movie-data"
                    },
                    "object": {
                        "key": "test.json"
                    }
                }
            }
        ]
    }
    handler(event, None)
