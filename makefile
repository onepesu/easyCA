HOST = $(shell hostname)
CA_CNF = ca/openssl.cnf
CA_BITS = 4096
CA_DAYS = 7300
SERVER_CNF = servers/openssl.cnf
SERVER_BITS = 2048
SERVER_DAYS = 730

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
	openssl genrsa ${ENC} -out $@ ${CA_BITS}
	chmod 400 $@

ca/certs/ca.crt:ca/private/ca.key | ca/certs ca/newcerts
	openssl req -new -x509 -sha256 -config ${CA_CNF} -days ${CA_DAYS} -key $< -out $@
	chmod 444 $@

ca/crl/ca.crl:ca/certs/ca.crt | ca/crl
	openssl ca -gencrl -config ${CA_CNF} -out $@

ca/index.txt:
	touch $@

ca/serial:
	echo 1000 > $@

servers/private/%.key: | servers/private
	openssl genrsa ${ENC} -out $@ ${SERVER_BITS}
	chmod 400 $@

servers/csr/%.csr:servers/private/${HOST}.key | servers/csr
	export DNS=$*; openssl req -config ${SERVER_CNF} -key $< -new -sha256 -out $@

servers/csr/%.ext: | servers/csr
	echo subjectAltName=DNS:$* > $@

servers/certs/%.crt:servers/csr/%.csr servers/csr/%.ext ca/certs/ca.crt | servers/certs ca/index.txt ca/serial
	openssl ca -batch -config ${CA_CNF} -days ${SERVER_DAYS} -in $< -out $@ -extfile $(word 2,$^)
	chmod 444 $@
