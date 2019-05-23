VERSION=0.0.1

all:
	docker build -t bbarker/purescript-macaulay2:$(VERSION) .
	docker tag bbarker/purescript-macaulay2:$(VERSION) bbarker/purescript-macaulay2:latest

push:
	docker push bbarker/purescript-macaulay2:$(VERSION)
	docker push bbarker/purescript-macaulay2:latest

withssh: 
	rm -f id_rsa*
	ssh-keygen -b 1024 -f id_rsa -P ''
	docker build -t "ssh-macaulay2:$(VERSION) -f ../Dockerfile .

run:
	docker run -i -t -u m2user -w /home/m2user -v /Users/mike/:/home/m2user/files:ro \
        bbarker/purescript-macaulay2:$(VERSION) M2

run-bash:
	docker run -i -t -u m2user -w /home/m2user -v /Users/mike/:/home/m2user/files:ro \
        bbarker/purescript-macaulay2:$(VERSION) bash

login:
	docker login --username=bbarker

