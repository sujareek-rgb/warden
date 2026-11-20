#!/bin/bash
# Run a JS file inside the open Taskfolio tab in Google Chrome and print the result.
# usage: tf.sh <file.js> [url-fragment]   (default fragment: "taskfolio"; escape non-ASCII as \uXXXX in the JS file)
# Needs Chrome: View > Developer > Allow JavaScript from Apple Events.
FRAG="${2:-taskfolio}"
osascript -l JavaScript -e "
const app=Application('Google Chrome');
const js=$(python3 -c 'import json,sys;print(json.dumps(open(sys.argv[1]).read()))' "$1");
const frag=$(python3 -c 'import json,sys;print(json.dumps(sys.argv[1]))' "$FRAG");
let r='NO TASKFOLIO TAB';
app.windows().forEach(w=>w.tabs().forEach(t=>{if(t.url().includes(frag))r=t.execute({javascript:js});}));
r"
