# How to build

* This OCI image is required to run the circleci pipeline at ccc

* Here is how to build and publish this image :

```bash
export DTAG="0.0.2"
export QUAY_BOT_USERNAME=pok-us-io+pokusbot
export QUAY_BOT_SECRET=VDZBCDRFCDRFCDRFCDRFDCRFDCRFDFDFDFDFFDFDFDFDFDFM5ELFI
echo "QUAY_BOT_USERNAME=[$QUAY_BOT_USERNAME]"
echo "QUAY_BOT_SECRET=[${QUAY_BOT_SECRET}]"
git clone	git@gitlab.com:second-bureau/pegasus/pokus/pokus.git pokustee/
cd pokustee/
git checkout feature/add_circleci_yaml
docker login -u="$QUAY_BOT_USERNAME" -p="$QUAY_BOT_SECRET" quay.io
docker build --no-cache -t "quay.io/pok-us-io/pokus_api_build:${DTAG}" -f .circleci/docker/library/mvn/Dockerfile ./.circleci/docker/library/mvn/
docker push "quay.io/pok-us-io/pokus_api_build:${DTAG}"
```
