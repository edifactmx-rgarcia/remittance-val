# Default UBL 2 two-phase validation for linux
#
# Syntax: validate remittance-xml-file

DP0=$( cd "$(dirname "$0")" ; pwd -P )

if [ $# -eq 0 ]
then
echo Syntax:  sh validate.sh  remittance-xml-file
exit 1
fi

if [ ! -f "$1" ]
then
echo Input XML file not found: \"$1\"
exit 1
fi

echo
echo "############################################################"
echo Validating remittance
echo "############################################################"

if [ -f "$1.error.txt" ]; then rm "$1.error.txt" ; fi
if [ -f "$1.svrl.xml" ];  then rm "$1.svrl.xml"  ; fi

echo ===== Phase 1: XSD schema validation =====
sh "$DP0/val/w3cschema.sh" "$DP0/remt.001.001.05.xsd" "$1" 2>&1 >"$1.error.txt"
errorRet=$?

if [ $errorRet -eq 0 ]
then echo No schema validation errors. ; rm "$1.error.txt"
else cat "$1.error.txt"; exit $errorRet
fi

echo ===== Phase 2: Remittance \"$1\" data integrity validation =====
sh "$DP0/val/xslt.sh" "$1" "$DP0/remt.001.001.05_dbnalliance_v1.0.xsl" "$1.svrl.xml" 2>"$1.error.txt"
errorRet=$?

if [ $errorRet -eq 0 ]
then
sh "$DP0/val/xslt.sh" "$1.svrl.xml" "$DP0/testSVRL4UBLerrors.xsl" /dev/null 2>"$1.error.txt"
errorRet=$?

if [ $errorRet -eq 0 ]
then echo No data integrity validation errors. ; rm "$1.svrl.xml" "$1.error.txt"
else cat "$1.error.txt"; exit $errorRet

fi #end of check of massaged SVRL

else cat "$1.error.txt"; exit $errorRet

fi #end of check of raw SVRL
