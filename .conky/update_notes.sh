#!/bin/bash

opscore jira list --mine --format=json  | jq -r '.[] | "\(.Key) \(.Title)"' > /home/wooh/.conky/jiras.txt
cat /home/wooh/todo.txt > /home/wooh/notes.txt
cat /home/wooh/.conky/jiras.txt >> /home/wooh/notes.txt
