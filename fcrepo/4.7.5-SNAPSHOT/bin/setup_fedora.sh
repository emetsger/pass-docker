#!/bin/sh

# Fedora 4 container to setup
REPO="$1"
LOG="setup_fedora.log"

function wait_until_up {
    CMD="curl -u bootstrap:bootstrap --write-out %{http_code} --silent -o /dev/stderr ${REPO}"
    echo "Waiting for response from Fedora via ${CMD}"
    RESULT=$(${CMD})
    until [ ${RESULT} -lt 400 ] && [ ${RESULT} -gt 199 ]
    do
        echo "Trying again, result was ${RESULT}"
        RESULT=$(${CMD})
        sleep 1
    done

    echo "OK, fedora is up: ${RESULT}"
}


function create_binary {
    file_path="$1"
    repo_path="$2"
    content_type=$(file -ib "$file_path")

    if [ "$repo_path" == "/" ]; then
	repo_path=""
    fi
	
    repo_path="$REPO/$repo_path"
	
    msg="Creating binary at $repo_path for $file_path"
    echo $msg
    echo -e "\n$msg\n" >> $LOG
    
    curl -# -u bootstrap:bootstrap -X PUT --upload-file "$file_path" -H "Content-Type: $content_type" "$repo_path" >> $LOG

    if [ $? -ne 0 ]; then
	echo "Failed"
	exit
    fi
}

function create_object {
    repo_path="$1"

    if [ "$repo_path" == "/" ]; then
	repo_path=""
    fi
	
    repo_path="$REPO/$repo_path"
    
    msg="Creating object at $repo_path"
    echo $msg
    echo -e "\n$msg\n" >> $LOG

    curl -# -u bootstrap:bootstrap -X PUT -H "Content-Type: text/turtle" "$repo_path" >> $LOG

    if [ $? -ne 0 ]; then
	echo "Failed"
	exit
    fi
}

function delete_object {
    repo_path="$REPO/$1"

    msg="Deleting object at $repo_path"
    echo $msg
    echo -e "\n$msg\n" >> $LOG

    curl -u bootstrap:bootstrap -X DELETE "$repo_path" >> $LOG
    curl -u bootstrap:bootstrap -X DELETE "$repo_path/fcr:tombstone" >> $LOG
}

wait_until_up
delete_object ""
create_object ""
create_object "contributors"
create_object "deposits"
create_object "files"
create_object "funders"
create_object "grants"
create_object "journals"
create_object "policies"
create_object "publications"
create_object "publishers"
create_object "repositories"
create_object "repositoryCopies"
create_object "submissions"
create_object "users"

curl -v -i -# -u bootstrap:bootstrap -X PUT -H "Content-Type: text/turtle" --data-binary "@conf/acl.ttl" ${REPO}/.acl
curl -v -i -# -u bootstrap:bootstrap -X PUT -H "Content-Type: text/turtle" --data-binary "@conf/authz.ttl" ${REPO}/.acl/authz
curl -v -i -# -u bootstrap:bootstrap -X PATCH -H "Content-Type: application/sparql-update" -d "INSERT { <> <http://www.w3.org/ns/auth/acl#accessControl> </fcrepo/rest/.acl> } WHERE {}" ${REPO}/
curl -v -i -# -u bootstrap:bootstrap -X PUT -H "Content-Type: text/turtle" --data-binary "@conf/nih.ttl" ${REPO}/repositories/nih
curl -v -i -# -u bootstrap:bootstrap -X PUT -H "Content-Type: text/turtle" --data-binary "@conf/js.ttl" ${REPO}/repositories/js
