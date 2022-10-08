import socket
import select
import pymssql
import hashlib

conn = pymssql.connect(server='127.0.0.1', port=1433, user='DragonNest', password='E6h7HsRXJbH8ays', database='DNMembership')

host = '127.0.0.1'          #Emulated IP
host2 = '127.0.0.1'   #Virtual IP
port = 6001 #Emulated Port
port2 = 5412 #Virtual Port

def ProcData(data):
    return data
	
print("Map Server start from " + host + ":" + str(port) +" to " + host2 + ":" + str(port2) +"\r\n")

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind(('127.0.0.1', port))

print("127.0.0.1 Server start at "+ str(port) +"\r\n")

client = socket.socket( socket.AF_INET, socket.SOCK_STREAM )
client.connect((host2, port2))

print(host +" Client connect to " + host2 + ":" + str(port2) + "\n")

server.listen()
inputs = [server,]

cursor = conn.cursor()

while 1:
    r_list, w_list, e_list=select.select(inputs, [], [], 1)
    for s in r_list:
        if(s == server):
            conn, address = s.accept()
            inputs.append(conn)
        else:
            try:
                msg=s.recv(20480)
                print("Get:" + repr(msg) + "\r\n")
                strlist = msg.split(b"'")
                if(len(strlist) == 10 and strlist[5] == b'I'):
                    cursor.execute("select * from Accounts where AccountName = %s and RLKTPassword = %s;",(strlist[2], hashlib.md5(strlist[3]).hexdigest().upper()))
                    output=cursor.fetchall()
                    if(len(output) == 1):
                        strlist[3] = b'0'
                    else:
                        strlist[3] = b'1'
                    msg = b"'".join(strlist)
                client.send(msg)
                buf = client.recv(20480)
                s.sendall(buf)
                print("Send:" + repr(buf) + "\r\n")
            except Exception as ex:
                inputs.remove(s)