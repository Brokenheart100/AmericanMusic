# docker run --name mysql1 -e MYSQL_ROOT_PASSWORD="123456" -p 3306:3306 -d mysql:latest

import mysql.connector
from mysql.connector import Error

def test_mysql_connection():
    config = {
        "host": "localhost",  # Docker 映射的主机 IP，本地一般用 localhost
        "port": 3306,         # Docker 中 MySQL 映射的端口（如 3306）
        "user": "root",       # MySQL 用户名（按实际配置，如 root）
        "password": "123456", # 你的 MySQL 密码（按 Docker 配置填）
        # "database": "mysql1"    # 要连接的数据库名（提前在 Docker 里建好或启动时配置）
    }

    try:
        # 尝试建立连接
        connection = mysql.connector.connect(**config)
        if connection.is_connected():
            print("✅ 连接成功！")
            # 可额外执行简单查询验证（如查版本）
            cursor = connection.cursor()
            cursor.execute("SELECT VERSION()")
            result = cursor.fetchone()
            print(f"MySQL 版本: {result[0]}")
            cursor.close()
        else:
            print("❌ 连接失败：未知原因")
    except Error as e:
        print(f"❌ 连接失败: {e}")
    finally:
        # 关闭连接
        if 'connection' in locals() and connection.is_connected():
            connection.close()

if __name__ == "__main__":
    test_mysql_connection()