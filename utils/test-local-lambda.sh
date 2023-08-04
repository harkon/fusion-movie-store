curl -X POST "http://localhost:3001/2015-03-31/functions/function/invocations" -H "Content-Type: application/json" \
     --data-binary "@s3-event.json"
