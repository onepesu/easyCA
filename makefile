HOST = $(shell hostname)
CA_CNF = ca/openssl.cnf
CA_BITS = 4096
CA_DAYS = 7300
SERVER_CNF = servers/openssl.cnf
SERVER_BITS = 2048
SERVER_DAYS = 730

.PRECIOUS: ca/private/ca.key servers/private/%.key

ca/private/ca.key:
	mkdir -m 700 -p ca/private
	openssl genrsa -aes256 -out $@ ${CA_BITS}
	chmod 400 $@

ca/certs/ca.crt:ca/private/ca.key
	mkdir -p ca/certs
	openssl req -new -x509 -sha256 -config ${CA_CNF} -days ${CA_DAYS} -key $< -out $@
	chmod 444 $@

ca/crl/ca.crl:ca/certs/ca.crt
	mkdir -p ca/crl
	openssl ca -gencrl -config ${CA_CNF} -out $@

servers/private/%.key:
	mkdir -m 700 -p servers/private
	openssl genrsa -aes256 -out $@ ${SERVER_BITS}
	chmod 400 $@

servers/csr/%.csr:servers/private/${HOST}.key
	mkdir -p servers/csr
	export DNS=$*; openssl req -config ${SERVER_CNF} -key $< -new -sha256 -out $@

servers/csr/%.ext:
	echo subjectAltName=DNS:$* > $@

servers/certs/%.crt:servers/csr/%.csr servers/csr/%.ext
	mkdir -p ca/newcerts servers/certs
	openssl ca -batch -config ${CA_CNF} -days ${SERVER_DAYS} -in $< -out $@ -extfile $(word 2,$^)
	chmod 444 $@
