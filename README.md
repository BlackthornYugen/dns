# import to gcloud

```
for tld in dev ca; do
    for name in jskw jsteelkw jsteel ; do
        gcloud dns record-sets import \
            --delete-all-existing \
            ${name}.${tld}.yml \
            --zone "${name}-${tld}"
    done
done
```

# export from gcloud

```
for tld in dev ca; do
    for name in jskw jsteelkw jsteel ; do
        gcloud dns record-sets export \
            ${name}.${tld}.yml \
            --zone "${name}-${tld}"
    done
done
```

# create new records

## Single CNAME

Here's how I created a cname on a single domain:

```
gcloud dns record-sets create poker.jskw.dev. \
    --rrdatas "poker.arrakis.jskw.dev." \
    --ttl="300" \
    --type="CNAME" \
    --zone="jskw-dev"
```

## Multiple As

Here's how I created several A records for the ip subdomain:

```
for tld in dev ca; do
    for name in jskw jsteelkw jsteel ; do
        gcloud dns record-sets create ip.${name}.${tld}. \
        --rrdatas=144.217.207.192 \
        --type=A \
        --ttl=60 \
        --zone "${name}-${tld}"
    done
done
```