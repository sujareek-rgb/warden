#!/bin/bash
# Helpers to fill the Taskfolio week page one entry at a time. Source it:  source scripts/tf-lib.sh
# Every entry is read back and compared with the confirmed row BEFORE saving; a mismatch cancels the dialog.
# Select values (Category, Subcategory, Project) are the option *values* of the dialog selects — read them first
# (see references/apply.md); Taskfolio ids differ per team.
#
#   do_edit DAY MATCH CAT SUB PROJ START END [DESC]     edit an existing draft/saved entry (DAY = MON|TUE|WED|THU|FRI)
#   do_add  DATE CAT SUB PROJ START END [JIRA] [DESC]   "+ Add" a new entry (DATE = YYYY-MM-DD)
#   del_entry DAY MATCH                                  delete a draft from the week page
#
# MATCH: the exact first line of the entry (the Jira key, e.g. PYR-123) or, for a meeting, its title.
# Never pass a prefix of a key (OLS-10 would also hit OLS-1049). Thai text must be written as \uXXXX.

_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T="$_here/tf.sh"
SD="${TF_SCRATCH:-${TMPDIR:-/tmp}/taskfolio-log}"
mkdir -p "$SD"
tf(){ bash "$T" "$SD/$1" "$TF_URL_FRAGMENT"; }
PRE='const g=id=>document.getElementById(id);const S=(el,v)=>{if(!el)throw new Error("missing el");if(![...el.options].some(o=>o.value===v))throw new Error("missing option "+v+" in "+el.id);Object.getOwnPropertyDescriptor(HTMLSelectElement.prototype,"value").set.call(el,v);el.dispatchEvent(new Event("change",{bubbles:true}));};'
run(){ printf '%s' "(function(){try{$PRE $1 }catch(e){return 'ERR '+e.message}})()" > "$SD/r.js"; tf r.js; }

# Duration Taskfolio will log for START END (it takes a flat 1 h off any span that overlaps 12:00-13:00).
fmt(){ python3 -c "
import sys
a,b=sys.argv[1],sys.argv[2]
m=lambda t:int(t[:2])*60+int(t[3:])
d=m(b)-m(a)
if m(a)<780 and m(b)>720: d-=60
h,mm=divmod(d,60)
print(' '.join(([f'{h} h'] if h else [])+([f'{mm} m'] if mm else [])))" "$1" "$2"; }

open_entry(){ run "const d=[...document.querySelectorAll('.day')].find(x=>x.innerText.trim().startsWith('$1'));if(!d)return 'no day';const e=[...d.querySelectorAll('.ent')].find(x=>{const l=x.innerText.split('\n').map(s=>s.trim());return l[0]==='$2'||(l[1]||'').startsWith('$2 ·');});if(!e)return 'no ent';const b=[...e.querySelectorAll('button')].find(x=>x.innerText.trim()==='Edit'||x.classList.contains('entbtn'));if(!b)return 'no btn';b.click();return 'clicked';"; }

save(){ run "const dl=document.querySelector('[role=dialog]');const b=[...dl.querySelectorAll('button')].find(x=>['Add entry','Save'].includes(x.innerText.trim()));if(!b)return 'no save btn';b.click();return 'saved-click';"; }

# Each select is set in its own call with a pause: the form re-renders between them (Project only fills after a Subcategory).
fill_common(){ # CAT SUB PROJ START END DESC
  r=$(run "const c='$1';if(c&&g('c').value!==c)S(g('c'),c);return 'ok'"); [ "$r" = ok ] || { echo "FAIL cat $r"; return 1; }; sleep 1
  r=$(run "S(g('i'),'$2');return 'ok'"); [ "$r" = ok ] || { echo "FAIL sub $r"; return 1; }; sleep 1
  r=$(run "S(g('pj'),'$3');S(g('ts'),'$4');return 'ok'"); [ "$r" = ok ] || { echo "FAIL pj/ts $r"; return 1; }; sleep 1
  r=$(run "S(g('te'),'$5');return 'ok'"); [ "$r" = ok ] || { echo "FAIL te $r"; return 1; }; sleep 1
  if [ -n "$6" ]; then r=$(run "const d=g('d');Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set.call(d,'$6');d.dispatchEvent(new Event('input',{bubbles:true}));return 'ok'"); [ "$r" = ok ] || { echo "FAIL desc $r"; return 1; }; sleep 1; fi
}

verify_save(){ # CAT SUB PROJ START END LABEL
  out=$(run "const c=document.querySelector('[role=dialog]').cloneNode(true);c.querySelectorAll('select').forEach(s=>s.remove());const t=c.innerText;const m=t.match(/15m30m1h2h4h8h−([^+]*)\\+/);return ['c','i','pj','ts','te'].map(k=>g(k).value).join(',')+'#'+(m?m[1].trim():'?')")
  exp="$1,$2,$3,$4,$5#$(fmt "$4" "$5")"
  if [ "$out" != "$exp" ]; then
    echo "MISMATCH $6: got [$out] expected [$exp] - NOT saved"
    run "[...document.querySelectorAll('[role=dialog] button')].find(x=>x.innerText.trim()==='Cancel').click();return 'cancelled'" >/dev/null
    return 1
  fi
  save >/dev/null; sleep 2; echo "OK $6 $4-$5 $(fmt "$4" "$5")"
}

do_edit(){ # DAY MATCH CAT SUB PROJ START END [DESC]
  r=$(open_entry "$1" "$2"); [ "$r" = clicked ] || { echo "OPEN FAIL $2: $r"; return 1; }; sleep 1
  fill_common "$3" "$4" "$5" "$6" "$7" "$8" || return 1
  verify_save "$3" "$4" "$5" "$6" "$7" "$1 $2"
}

do_add(){ # DATE CAT SUB PROJ START END [JIRA] [DESC]
  r=$(run "const b=document.querySelector('button.addbtn[data-add=\"$1\"]');if(!b)return 'no add';b.click();return 'clicked'"); [ "$r" = clicked ] || { echo "ADD OPEN FAIL $1: $r"; return 1; }; sleep 1
  fill_common "$2" "$3" "$4" "$5" "$6" "$8" || return 1
  if [ -n "$7" ]; then
    # Typing the Jira key can reset Project: type it, then set Project again.
    r=$(run "const d=g('j');Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set.call(d,'$7');d.dispatchEvent(new Event('input',{bubbles:true}));return 'ok'"); [ "$r" = ok ] || { echo "FAIL jira $r"; return 1; }; sleep 1
    r=$(run "S(g('pj'),'$4');return g('pj').value"); [ "$r" = "$4" ] || { echo "FAIL pj reset $r"; return 1; }; sleep 1
  fi
  verify_save "$2" "$3" "$4" "$5" "$6" "ADD $1 $7 $8"
}

del_entry(){ # DAY MATCH  (drafts only: the confirm button reads "Delete draft"; a saved entry says "Delete entry")
  r=$(run "const d=[...document.querySelectorAll('.day')].find(x=>x.innerText.trim().startsWith('$1'));const e=[...d.querySelectorAll('.ent')].find(x=>{const l=x.innerText.split('\n').map(s=>s.trim());return (l[1]||'').startsWith('$2')||l[0]==='$2';});if(!e)return 'no ent';const b=[...e.querySelectorAll('button')].find(x=>x.innerText.trim()==='Delete');if(!b)return 'no del btn';b.click();return 'clicked';"); [ "$r" = clicked ] || { echo "DEL OPEN FAIL $2: $r"; return 1; }; sleep 1
  r=$(run "const b=[...document.querySelectorAll('[role=dialog] button,[role=alertdialog] button')].find(x=>['Delete entry','Delete draft'].includes(x.innerText.trim()));if(!b)return 'no confirm';b.click();return 'deleted-click';")
  echo "$1 $2 -> $r"; sleep 2
}
