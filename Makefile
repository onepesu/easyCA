ALGO = ED25519
CA_CONF = ca/openssl.conf
CA_DAYS = 7300
SERVER_CONF = servers/openssl.conf
SERVER_DAYS = 730

.PRECIOUS: ca/private/ca.key servers/private/server.key
.PRECIOUS: %/private %/certs ca/crl ca/newcerts servers/csr

%/private:
	mkdir -m 700 -p $@

%/certs:
	mkdir -p $@

ca/crl:
	mkdir -p $@

ca/newcerts:
	mkdir -p $@

servers/csr:
	mkdir -p $@

ca/private/ca.key: | ca/private
	openssl genpkey -algorithm $(ALGO) -out $@
	chmod 400 $@

ca/certs/ca.crt: ca/private/ca.key $(CA_CONF) | ca/certs ca/newcerts
	openssl req -new -x509 -sha256 -config $(word 2,$^) -days $(CA_DAYS) -key $< -out $@
	chmod 444 $@

ca/crl/ca.crl: ca/certs/ca.crt | ca/crl
	openssl ca -gencrl -config $(CA_CONF) -out $@

ca/index.txt:
	touch $@

ca/serial:
	echo 1000 > $@

servers/private/server.key: | servers/private
	openssl genpkey -algorithm $(ALGO) -out $@
	chmod 400 $@

servers/csr/%.csr: servers/private/server.key $(SERVER_CONF) | servers/csr
	COMMON_NAME_DEFAULT=$* openssl req -config $(word 2,$^) -key $< -new -sha256 -out $@

servers/csr/%.ext: | servers/csr
	echo subjectAltName=DNS:$* > $@

servers/certs/%.crt: servers/csr/%.csr servers/csr/%.ext ca/certs/ca.crt | servers/certs ca/index.txt ca/serial
	openssl ca -batch -config $(CA_CONF) -days $(SERVER_DAYS) -in $< -out $@ -extfile $(word 2,$^)
	chmod 444 $@
