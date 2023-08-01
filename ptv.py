import json
import sys

from trim import trim

if (sys.argv[1] == 'TRIM'):
    file = sys.argv[2]

    json_content = ""

    with open(file, 'r') as content_file:
        json_content = content_file.read()

    jobject = json.loads(json_content)
    jobject = trim(jobject)
    print(json.dumps(jobject, indent=2))

else:
    print('ERROR: Unknown command.')
