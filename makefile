HOST = $(shell hostname)
EMAIL = $(file < email_default)
ALGO = RSA
CA_CNF = ca/openssl.cnf
CA_DAYS = 7300
CA_BITS = 4096
CA_OPTS = rsa_keygen_bits:$(CA_BITS)
SERVER_CNF = servers/openssl.cnf
SERVER_DAYS = 730
SERVER_BITS = 2048
SERVER_OPTS = rsa_keygen_bits:$(SERVER_BITS)

.PRECIOUS: ca/private/ca.key servers/private/%.key
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
	openssl genpkey -algorithm $(ALGO) -pkeyopt $(CA_OPTS) -out $@
	chmod 400 $@

ca/ca.cnf: $(CA_CNF)
	sed 's/{{emailAddress}}/$(EMAIL)/g' $< > $@

ca/certs/ca.crt: ca/private/ca.key ca/ca.cnf | ca/certs ca/newcerts
	openssl req -new -x509 -sha256 -config $(word 2,$^) -days $(CA_DAYS) -key $< -out $@
	chmod 444 $@

ca/crl/ca.crl: ca/certs/ca.crt | ca/crl
	openssl ca -gencrl -config $(CA_CNF) -out $@

ca/index.txt:
	touch $@

ca/serial:
	echo 1000 > $@

servers/private/%.key: | servers/private
	openssl genpkey -algorithm $(ALGO) -pkeyopt $(SERVER_OPTS) -out $@
	chmod 400 $@

servers/%.cnf: $(SERVER_CNF)
	sed 's/{{emailAddress}}/$(EMAIL)/g;s/{{commonName}}/$*/g' $< > $@

servers/csr/%.csr: servers/private/$(HOST).key servers/%.cnf | servers/csr
	openssl req -config $(word 2,$^) -key $< -new -sha256 -out $@

servers/csr/%.ext: | servers/csr
	echo subjectAltName=DNS:$* > $@

servers/certs/%.crt: servers/csr/%.csr servers/csr/%.ext ca/certs/ca.crt | servers/certs ca/index.txt ca/serial
	openssl ca -batch -config $(CA_CNF) -days $(SERVER_DAYS) -in $< -out $@ -extfile $(word 2,$^)
	chmod 444 $@
