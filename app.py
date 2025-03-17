from flask import Flask, render_template, request
import mysql.connector


app = Flask(__name__, static_folder='static', template_folder='templates')



db_config = {
    'host': 'pydemo1.mysql.pythonanywhere-services.com',
    'user': 'pydemo1',
    'password': 'demoroot',
    'database': 'pydemo1$default'
}

@app.route('/', methods=['GET', 'POST'])
def index():
    results = None
    error = None
    if request.method == 'POST':

        query = request.form['query']
        
       
        try:
            connection = mysql.connector.connect(**db_config)
            cursor = connection.cursor(dictionary=True)  
            
            cursor.execute(query)
            results = cursor.fetchall()  
            cursor.close()
            connection.close()
        except mysql.connector.Error as err:
            
            error = f"Error: {err}"

    
    return render_template('index.html', results=results, error=error)


if __name__ == '__main__':
    app.run(debug=True)
