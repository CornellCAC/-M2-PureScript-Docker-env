VERSION=0.0.1
PS_VERSION=0.12.5
PS_NATIVE_COMMIT=aa857adec6aa40edac91bcacfe4c3b7c5f1c3f2d

all:
	docker build --build-arg PS_VERSION=$(PS_VERSION) \
		-t bbarker/purescript-macaulay2:$(VERSION) .
	docker tag bbarker/purescript-macaulay2:$(VERSION) \
		bbarker/purescript-macaulay2:latest
	docker tag bbarker/purescript-macaulay2:$(VERSION) \
		purescript-macaulay2:latest

push:
	docker push bbarker/purescript-macaulay2:$(VERSION)
	docker push bbarker/purescript-macaulay2:latest

withssh:
	rm -f id_rsa*
	ssh-keygen -b 1024 -f id_rsa -P ''
	docker build -t "ssh-macaulay2:$(VERSION)" -f ../Dockerfile .

run:
	docker run -i -t -u m2user -w /home/m2user -v /Users/mike/:/home/m2user/files:ro \
        bbarker/purescript-macaulay2:$(VERSION) M2

run-bash:
	docker run -i -t -u m2user -w /home/m2user -v /Users/mike/:/home/m2user/files:ro \
        bbarker/purescript-macaulay2:$(VERSION) bash

login:
	docker login --username=bbarker

