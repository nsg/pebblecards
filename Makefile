LOCAL_IMAGE_NAME = pebblecards
USERNAME = nsgb
APP_NAME = pebblecards
TAGTMPFILE=/tmp/makefile-${LOCAL_IMAGE_NAME}.tag

build:
	docker build -t $(LOCAL_IMAGE_NAME) .

rebuild:
	docker build --no-cache -t $(LOCAL_IMAGE_NAME) .

run: build
	docker run -tip 8080:80 -v $$PWD:/usr/share/nginx/html $(LOCAL_IMAGE_NAME)

debug: build
	docker run -tip 8080:5000 -v $$PWD:/usr/share/nginx/html \
		--entrypoint=/usr/local/bin/debug $(LOCAL_IMAGE_NAME)

clean:
	docker rmi $(LOCAL_IMAGE_NAME) || :
	docker rmi $$(docker images -qf "dangling=true") || :

nexttag:
	echo $$(date +\%Y\%m\%d\%H\%M\%S) > $(TAGTMPFILE)

tag: nexttag
	docker tag $(LOCAL_IMAGE_NAME) $(USERNAME)/$(APP_NAME):$$(cat $(TAGTMPFILE)) || :

push: build tag
	docker push $(USERNAME)/$(APP_NAME):$$(cat $(TAGTMPFILE))

deploy: push
	shdeploy deploy \
		-a pebblecards \
		-i $(USERNAME)/$(APP_NAME):$$(cat $(TAGTMPFILE)) \
		-o nsg.cc
