#!/bin/bash
set -ex

lunaclient () {
    NOW="$(date +%Y%m%d)"
    cp /usr/safenet/lunaclient/Chrystoki-template.conf /usr/safenet/lunaclient/config/Chrystoki.conf
    cd /usr/safenet/lunaclient/libs/64/
    rm -f libCryptoki2_64.so
    ln -s libCryptoki2.so libCryptoki2_64.so
    /usr/safenet/lunaclient/bin/64/configurator setValue -s Chrystoki2 -e LibUNIX -v /usr/safenet/lunaclient/libs/64/libCryptoki2.so
    /usr/safenet/lunaclient/bin/64/configurator setValue -s Chrystoki2 -e LibUNIX64 -v /usr/safenet/lunaclient/libs/64/libCryptoki2_64.so
    /usr/safenet/lunaclient/bin/64/configurator setValue -s Misc -e ToolsDir -v /usr/safenet/lunaclient/bin/64/
    /usr/safenet/lunaclient/bin/64/configurator setValue -s Misc -e MutexFolder -v /usr/safenet/lunaclient/lock
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "LunaSA Client" -e SSLConfigFile -v /usr/safenet/lunaclient/openssl.cnf
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "LunaSA Client" -e ServerCAFile -v /usr/safenet/lunaclient/config/certs/CAFile.pem
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "LunaSA Client" -e "ClientCertFile" -v /usr/safenet/lunaclient/config/certs/
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "LunaSA Client" -e "ClientPrivKeyFile" -v /usr/safenet/lunaclient/config/certs/
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "Secure Trusted Channel" -e ClientTokenLib -v /usr/safenet/lunaclient/libs/64/libSoftToken.so
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "Secure Trusted Channel" -e SoftTokenDir -v /usr/safenet/lunaclient/config/stc/token
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "Secure Trusted Channel" -e ClientIdentitiesDir -v /usr/safenet/lunaclient/config/stc/client_identities
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "Secure Trusted Channel" -e PartitionIdentitiesDir -v /usr/safenet/lunaclient/config/stc/partition_identities

    /usr/safenet/lunaclient/bin/64/configurator setValue -s "VirtualToken" -e VirtualToken00Label -v {{ .Values.lunaclient.VirtualToken.VirtualToken00Label }}
    {{- if eq .Values.hsm.ha.enabled true }}
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "VirtualToken" -e VirtualToken00SN -v 1{{ .Values.lunaclient.VirtualToken.VirtualToken00SN }}
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "VirtualToken" -e VirtualToken00Members -v {{ .Values.lunaclient.VirtualToken.VirtualToken00Members }},{{ .Values.lunaclient.VirtualToken.VirtualToken00Members02 }}
    {{- else}}
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "VirtualToken" -e VirtualToken00SN -v {{ .Values.lunaclient.VirtualToken.VirtualToken00SN }}
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "VirtualToken" -e VirtualToken00Members -v {{ .Values.lunaclient.VirtualToken.VirtualToken00Members }}
    {{- end}}

    /usr/safenet/lunaclient/bin/64/configurator setValue -s "VirtualToken" -e VirtualTokenActiveRecovery -v {{ .Values.lunaclient.VirtualToken.VirtualTokenActiveRecovery }}
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "HASynchronize" -e {{ .Values.lunaclient.VirtualToken.VirtualToken00Label }} -v {{ .Values.lunaclient.HASynchronize.sync }}
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "HAConfiguration" -e haLogStatus -v {{ .Values.lunaclient.HAConfiguration.haLogStatus }}
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "HAConfiguration" -e reconnAtt -v {{ .Values.lunaclient.HAConfiguration.reconnAtt }}
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "HAConfiguration" -e HAOnly -v {{ .Values.lunaclient.HAConfiguration.HAOnly }}
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "HAConfiguration" -e haLogPath -v {{ .Values.lunaclient.HAConfiguration.haLogPath }}
    /usr/safenet/lunaclient/bin/64/configurator setValue -s "HAConfiguration" -e logLen -v {{ .Values.lunaclient.HAConfiguration.logLen }}
    /usr/safenet/lunaclient/bin/64/vtl createCert -n $HOSTNAME-$NOW

    #REGISTER HSM1
    /usr/safenet/lunaclient/bin/64/pscp -pw {{ .Values.lunaclient.conn.pwd }} /usr/safenet/lunaclient/config/certs/$HOSTNAME-$NOW.pem {{ .Values.lunaclient.conn.user }}@{{ .Values.lunaclient.conn.ip }}:.
    /usr/safenet/lunaclient/bin/64/pscp -pw {{ .Values.lunaclient.conn.pwd }} {{ .Values.lunaclient.conn.user }}@{{ .Values.lunaclient.conn.ip }}:server.pem /usr/safenet/lunaclient/config/certs/
    /usr/safenet/lunaclient/bin/64/vtl addserver -n {{ .Values.lunaclient.conn.ip }} -c  /usr/safenet/lunaclient/config/certs/server.pem
    echo "client register -c $HOSTNAME-$NOW" -h $HOSTNAME-$NOW > /usr/safenet/lunaclient/config/$HOSTNAME-$NOW.txt
    echo "client assignPartition -c $HOSTNAME-$NOW -p {{ .Values.lunaclient.conn.par }}" >> /usr/safenet/lunaclient/config/$HOSTNAME-$NOW.txt
    echo "exit" >> /usr/safenet/lunaclient/config/$HOSTNAME-$NOW.txt
    /usr/safenet/lunaclient/bin/64/plink {{ .Values.lunaclient.conn.ip }} -ssh -l {{ .Values.lunaclient.conn.user }} -pw {{ .Values.lunaclient.conn.pwd }} -v < /usr/safenet/lunaclient/config/$HOSTNAME-$NOW.txt
    
    {{- if eq .Values.hsm.ha.enabled true }}
    #REGISTER HSM2
    /usr/safenet/lunaclient/bin/64/pscp -pw {{ .Values.lunaclient.conn.pwd }} /usr/safenet/lunaclient/config/certs/$HOSTNAME-$NOW.pem {{ .Values.lunaclient.conn.user }}@{{ .Values.lunaclient.conn.ip02 }}:.
    /usr/safenet/lunaclient/bin/64/pscp -pw {{ .Values.lunaclient.conn.pwd }} {{ .Values.lunaclient.conn.user }}@{{ .Values.lunaclient.conn.ip02 }}:server.pem /usr/safenet/lunaclient/config/certs/
    /usr/safenet/lunaclient/bin/64/vtl addserver -n {{ .Values.lunaclient.conn.ip02 }} -c  /usr/safenet/lunaclient/config/certs/server.pem
    echo "client register -c $HOSTNAME-$NOW" -h $HOSTNAME-$NOW > /usr/safenet/lunaclient/config/$HOSTNAME-$NOW-02.txt
    echo "client assignPartition -c $HOSTNAME-$NOW -p {{ .Values.lunaclient.conn.par02 }}" >> /usr/safenet/lunaclient/config/$HOSTNAME-$NOW-02.txt
    echo "exit" >> /usr/safenet/lunaclient/config/$HOSTNAME-$NOW-02.txt
    /usr/safenet/lunaclient/bin/64/plink {{ .Values.lunaclient.conn.ip02 }} -ssh -l {{ .Values.lunaclient.conn.user }} -pw {{ .Values.lunaclient.conn.pwd }} -v < /usr/safenet/lunaclient/config/$HOSTNAME-$NOW-02.txt
    {{- end}}
    
    cp /usr/safenet/lunaclient/config/Chrystoki.conf /etc/Chrystoki.conf
    }

{{- if eq .Values.hsm.enabled true }}
lunaclient
{{- end }}
