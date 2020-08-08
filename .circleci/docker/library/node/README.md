# How to build

* This OCI image is required to run the circleci pipeline at ccc

* Here is how to buidl and publish this image :

```bash
export DTAG="0.0.2"
export QUAY_BOT_USERNAME=pok-us-io+pokusbot
export QUAY_BOT_SECRET=VDZBCDRFCDRFCDRFCDRFDCRFDCRFDFDFDFDFFDFDFDFDFDFM5ELFI
echo "QUAY_BOT_USERNAME=[$QUAY_BOT_USERNAME]"
echo "QUAY_BOT_SECRET=[${QUAY_BOT_SECRET}]"
git clone	git@github.com:pok-us-io/gravitee-gateway.git gravitotee/
cd gravitotee/
git checkout feature/add_circleci_yaml
docker build --no-cache -t "quay.io/pok-us-io/pokus_api_build:${DTAG}" -f .circleci/docker/library/mvn/Dockerfile ./.circleci/docker/primary/mvn/
docker login -u="$QUAY_BOT_USERNAME" -p="$QUAY_BOT_SECRET" quay.io
docker push "quay.io/pok-us-io/pokus_api_build:${DTAG}"
```
