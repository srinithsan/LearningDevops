RunXML=$1
BuildXML=$2
UserInput=$3
GV_Gen_Run=${RunXML}".txt"
GV_Gen_Build=${BuildXML}".txt"
Feeder_File=${RunXML}".feeder"
#cp $RunXML ${RunXML}".backup"

rm -f ${UserInput}".failed"
rm -f ${GV_Gen_Run}
rm -f ${GV_Gen_Build}
rm -f $Feeder_File

echo "[`date`]::INFO::Changing RV GV SV to its full form in GV config file" >> ${MAIL_LOG}
grep -v '^[[:blank:]]*$' $UserInput > ${UserInput}".tmp"
mv ${UserInput}".tmp" $UserInput
perl -pi -e 's/RV~/Runtime Variables~/g' $UserInput
perl -pi -e 's/AV~/Adapter SDK Properties~/g' $UserInput

parName=`grep -w "bw name" ${RunXML} | awk -F '"' '{print $2}'`
if [ -z $parName ]; then
depxmlType=be
else
depxmlType=bw
fi

lines=`cat $UserInput`
if [ -f ${UserInput}".tmp" ]; then
rm -f ${UserInput}".tmp"
fi

while IFS= read -r line; do
        isGV=`echo $line | grep -v "Runtime Variables~" | grep -v "Adapter SDK Properties~" | grep -v "BD~" | grep -v "PV~" | grep -v "PN~" | grep -v "Global Variables~"`
        if [ ! "$isGV" == "" ]; then
                echo "Global Variables~"${isGV} >> ${UserInput}".tmp"
        else
                echo $line >> ${UserInput}".tmp"
        fi
done < ${UserInput}
mv ${UserInput}".tmp" ${UserInput}


sed 's/\\/_b_/g' ${UserInput} > ${UserInput}".tmp"
mv ${UserInput}".tmp" ${UserInput}
cat $UserInput | grep -v "^$" | while IFS='=' read attTmpPar attValue
do
isWin=`echo $attValue | grep '_b_'`

if [ ! -z "$isWin" ]; then
echo 'CNG~invalid~'${attTmpPar} >> ${MAIL_LOG}
fi

done

sed '/_b_/d' ${UserInput} > ${UserInput}".tmp"
mv ${UserInput}".tmp" ${UserInput}





cat ${UserInput} | grep -v "BD~" | awk -F\~ '{ print $1 }' | sort | uniq > ${UserInput}".tmp"


while IFS= read -r Type; do

if [ "$depxmlType" == "bw" ]; then
Service="/p:services/p:bw"
else
Service="/p:services/p:service"
fi

if [ "$Type" == "Global Variables" ]; then
Service=""
fi

echo "[`date`]::INFO::Extracting ${Type} NameValuePairs from Run XML" >> ${MAIL_LOG}
cat  $RunXML | xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -t   -m "/p:application${Service}/p:NVPairs[@name='${Type}']/p:NameValuePair" -n -v "concat('${Type}','~','$RunXML','~','NameValuePair','~',p:name,'~',p:value)"  >> ${GV_Gen_Run}
cat  $RunXML | xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -t   -m "/p:application${Service}/p:NVPairs[@name='${Type}']/p:NameValuePairInteger" -n  -v  "concat('${Type}','~','$RunXML','~','NameValuePairInteger','~',p:name,'~',p:value)"  >> ${GV_Gen_Run}
cat  $RunXML | xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -t   -m "/p:application${Service}/p:NVPairs[@name='${Type}']/p:NameValuePairPassword" -n -v  "concat('${Type}','~','$RunXML','~','NameValuePairPassword','~',p:name,'~',p:value)"  >> ${GV_Gen_Run}
cat  $RunXML | xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -t   -m "/p:application${Service}/p:NVPairs[@name='${Type}']/p:NameValuePairBoolean" -n  -v  "concat('${Type}','~','$RunXML','~','NameValuePairBoolean','~',p:name,'~',p:value)"  >> ${GV_Gen_Run}

done < ${UserInput}".tmp"

grep -v "^$" ${GV_Gen_Run} > ${GV_Gen_Run}".tmp"
mv  ${GV_Gen_Run}".tmp" ${GV_Gen_Run}

while IFS= read -r Type; do

if [ "$depxmlType" == "bw" ]; then
Service="/p:services/p:bw"
else
Service="/p:services/p:service"
fi

if [ "$Type" == "Global Variables" ]; then
Service=""
fi
echo "[`date`]::INFO::Extracting ${Type} NameValuePairs from Build XML" >> ${MAIL_LOG}
cat  $BuildXML | xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -t   -m "/p:application${Service}/p:NVPairs[@name='${Type}']/p:NameValuePair" -n -v "concat('${Type}','~','$RunXML','~','NameValuePair','~',p:name,'~',p:value)"  >> ${GV_Gen_Build}
cat  $BuildXML | xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -t   -m "/p:application${Service}/p:NVPairs[@name='${Type}']/p:NameValuePairInteger" -n  -v  "concat('${Type}','~','$RunXML','~','NameValuePairInteger','~',p:name,'~',p:value)"  >> ${GV_Gen_Build}
cat  $BuildXML | xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -t   -m "/p:application${Service}/p:NVPairs[@name='${Type}']/p:NameValuePairPassword" -n -v  "concat('${Type}','~','$RunXML','~','NameValuePairPassword','~',p:name,'~',p:value)"  >> ${GV_Gen_Build}
cat  $BuildXML | xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -t   -m "/p:application${Service}/p:NVPairs[@name='${Type}']/p:NameValuePairBoolean" -n  -v  "concat('${Type}','~','$RunXML','~','NameValuePairBoolean','~',p:name,'~',p:value)"  >> ${GV_Gen_Build}
done < ${UserInput}".tmp"

rm -f ${UserInput}".tmp"

grep -v "^$" ${GV_Gen_Build} > ${GV_Gen_Build}".tmp"
mv  ${GV_Gen_Build}".tmp" ${GV_Gen_Build}


        echo -e "---------------------------------------Changes Provided by Requestor--------------------------------------------\n"
        cat $UserInput | while IFS='\=' read cfgline1 cfgline2;
        do
                #UValue=`echo $cfgline1 | awk -F\~ '{ print $2 }'`
                echo $cfgline1
        done
        echo  -e "----------------------------------------------------------------------------------------------------------------\n"

	echo "[`date`]::INFO::Generating feeder file" >> ${MAIL_LOG}
        cat $UserInput | grep -v "BD~" | grep -v "PN~" | grep -v "PV~" | while IFS= read -r thisVal
        do
#		thisVal=`cat $UserInput | grep -v "BD~" | grep -v "PN~" | grep -v "PV~" | sed "${countval}q;d"`
		two="$( cut -d '=' -f 2- <<< "$thisVal" )";
		one="$( cut -d '=' -f 1 <<< "$thisVal" )";
		countval=`expr $countval + 1`
		UType=`echo $one | awk -F\~ '{ print $1 }'`
		UAttr=`echo $one | awk -F\~ '{ print $2 }'`
		isRun=`grep "$UAttr" ${GV_Gen_Run} | grep "$UType"`
		isBuild=`grep "$UAttr" ${GV_Gen_Build} | grep "$UType"`
		if [ ! "$isRun" == "" ]; then
                grep -w "$UAttr" ${GV_Gen_Run} | grep -w "$UType" | awk -F\~ -v value="$two" '{ print $1"~"$2"~"$3"~"$4"~"value }' >>  $Feeder_File
		elif [ ! "$isBuild" == "" ]; then
		grep -w "$UAttr" ${GV_Gen_Build} | grep -w "$UType" | awk -F\~ -v value="$two" '{ print $1"~"$2"~"$3"~"$4"~"value }' >>  $Feeder_File
		echo "$one=$two"
		else
		echo "Not a Valid GV $one=$two"
		echo "$one $two" >> ${UserInput}".failed"
		echo 'CNG~invalid~'$one >> ${MAIL_LOG}
		fi
        done

grep -v '^[[:blank:]]*$' ${UserInput}".failed" > ${UserInput}".failed.tmp"
mv ${UserInput}".failed.tmp" ${UserInput}".failed"


echo "[`date`]::INFO::Updating GV changes" >> ${MAIL_LOG}
cat $Feeder_File | grep -vi "^$" | while IFS='~' read one two three four five
do
MVTYPE=$one
GV_SOURCE=`basename $two`
VTYPE=`echo $three`
GV_SOURCE_DIR=`dirname $two`
fname=`find $GV_SOURCE_DIR -name $GV_SOURCE`
tfname=`basename $fname`
if [ ! -z "$fname" ]
then

if [ "$depxmlType" == "bw" ]; then
Service="/p:services/p:bw"
else
Service="/p:services/p:service"
fi

if [ "$MVTYPE" == "Global Variables" ]; then
Service=""
fi

CMD="cat $fname|xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -T -t -v \"/p:application${Service}/p:NVPairs[@name='${MVTYPE}']/p:$VTYPE[p:name='$four']/p:name\""
echo $CMD > /tmp/check$$.sh
check=`sh /tmp/check$$.sh`
rm -f  /tmp/check$$.sh
#exit
if [  -z "$check" ]
then
  echo "Resource $three  -  $MVTYPE Pair not exists in $one"


CMD="cat $fname|xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -T -t -v \"/p:application${Service}/p:NVPairs[@name='${MVTYPE}']/p:$VTYPE[p:name='$four']/p:name\"" 
echo $CMD > /tmp/check$$.sh
check=`sh /tmp/check$$.sh`
rm -f  /tmp/check$$.sh
if [ ! -z "$check" ]
then
  echo "Resource $three  -  ${MVTYPE} Pair already defined in $one"
else
cat $fname | xml ed -N p=http://www.tibco.com/xmlns/ApplicationManagement \
-s "/p:application${Service}/p:NVPairs[@name='${MVTYPE}']" --type elem -n ResourceTMP -v ""  \
-s "/p:application${Service}/p:NVPairs[@name='${MVTYPE}']/ResourceTMP" --type elem -n name -v $four \
-s "/p:application${Service}/p:NVPairs[@name='${MVTYPE}']/ResourceTMP" --type elem -n value -v "$five" \
-r  //ResourceTMP -v $VTYPE | xml fo > $GV_SOURCE_DIR/$tfname$$ 
#exit
if [ $? -eq 0 ]
then
        echo "Added Successfully $four name in $fname"
	echo 'CNG~valid~'${MVTYPE}'~'${four} >> ${MAIL_LOG}
        cp $GV_SOURCE_DIR/$tfname$$ $fname
        rm -f $tfname$$
#       rm $tfname$$.sh
 
fi
fi

else
echo "cat $fname | xml ed -P -S -N p=http://www.tibco.com/xmlns/ApplicationManagement  -u \"/p:application${Service}/p:NVPairs[@name='${MVTYPE}']/p:$VTYPE[p:name='$four']/p:value\" -v \"$five\"  > $GV_SOURCE_DIR/$tfname$$" > /tmp/temp1$$.sh
sh /tmp/temp1$$.sh
if [ $? -eq 0 ]
then
        echo "Updated Successfully $four name in $fname " >> ${UserInput}".success"
	echo 'CNG~valid~'${MVTYPE}'~'${four} >> ${MAIL_LOG}
        echo "Updated Successfully $four name in $fname " >> $2.log
        cp $GV_SOURCE_DIR/$tfname$$ $fname
        CMD="cat $fname|xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -T -t -v \"/p:application${Service}/p:NVPairs[@name='${MVTYPE}']/p:$VTYPE[p:name='$four']/p:value\""
        echo $CMD > /tmp/check$$.sh
        check=`sh /tmp/check$$.sh`
        rm -f  /tmp/check$$.sh
        echo "$two,$four=$check" >> $1_value.txt
        rm -f $GV_SOURCE_DIR/$tfname$$
        rm -f temp1$$.sh
else
        echo "Not Updated Successfully $three name in $fname " > $2.faillog
       #echo "Not Updated Successfully $three name in $fname "
        rm -f $GV_SOURCE_DIR/$tfname$$
        rm -f temp1$$.sh
	echo 'CNG~invalid~'${MVTYPE}'~'${four} >> ${MAIL_LOG}

fi
fi
else
    echo $fname is not found >> $2.log
fi
done

rm -f ${GV_Gen_Run}
rm -f ${GV_Gen_Build}
rm -f $1_value.txt


function checkNode {
newNode=$1
nodesFile=${SCRIPT_DIR}/allowedNodes.ini
isNode=`grep -wi $newNode $nodesFile`
if [ -z "$isNode" ]; then
echo "invalid"
else
echo "valid"
fi

}

if [ "$depxmlType" == "bw" ]; then
modxmlPath="bw"
else
modxmlPath="service"
fi

echo "updating Bindings"

echo "[`date`]::INFO::Updating Bindings" >> ${MAIL_LOG}
cat $UserInput | grep -v "^$" | grep "BD~" | while IFS= read -r thisVal
do
#thisVal=`cat $UserInput | grep -v "^$" | grep "BD~" | sed "${countval}q;d"`
attValue="$( cut -d '=' -f 2- <<< "$thisVal" )";
attTmpPar="$( cut -d '=' -f 1 <<< "$thisVal" )"
countval=`expr $countval + 1`

attPar=`echo "$attTmpPar" | awk -F\~ '{ print $2 }'`
parName=`echo $attPar | awk -F\/ '{ print $1 }'`
isMachine=`echo $attPar | awk -F '/' '{ print $2 }'`
isNVPairs=`echo $attPar | awk -F '/' '{ print $3 }'`

CMD="cat $RunXML|xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -T -t -v \"/p:application/p:services/p:${modxmlPath}[@name='${parName}']\""
echo $CMD > /tmp/check$$.sh
check=`sh /tmp/check$$.sh`
rm -f  /tmp/check$$.sh
if [ -z "$check" ]; then
echo "${parName} Par/Bar doesn't exist"
echo 'CNG~invalid~BD~'${attPar} >> ${MAIL_LOG}
exit 5
fi

if [ "$isMachine" == "machine" ]; then

echo "machine"
echo "[`date`]::INFO::Running addBindings.sh" >> ${MAIL_LOG}
$SCRIPT_DIR/addBindings.sh "$RunXML" "$parName" "$APP_NAME" "$attValue"
else
instHostName=`echo $attPar | awk -F\/ '{ print $2 }' | awk -F '_' '{ print $1 }'`
instNo=`echo $attPar | awk -F\/ '{ print $2 }' | awk -F '_' '{ print $2 }'`
if [ -z "$instNo" ]; then
instNames=`grep -B 2 ${instHostName} ${RunXML} | grep "binding name" | awk -F '="' '{ print $2 }' | awk -F '">' '{ print $1 }'`
else
instNames=`grep -B 2 ${instHostName} ${RunXML} | grep "binding name" | awk -F '="' '{ print $2 }' | awk -F '">' '{ print $1 }' | sort | sed "${instNo}q;d"`
fi
attName=`echo ${attPar} | rev | awk -F\/ '{ print $1 }' | rev`
tmpval=`echo ${attPar} | rev`; IFS='/' read -r one two <<< "$tmpval"
tmp1Path=`echo $two | rev`
IFS='/' read -r one two three <<< "$tmp1Path"
tmp2Path=$three
attPath=`echo $three | perl -p -i -e 's/\//\/p:/g'`

for instName in $instNames; do

if [ "$isNVPairs" == "NVPairs" ]; then
echo "NVPairs"
NVPairsName=`echo $attPar | awk -F 'NVPairs/' '{ print $2 }'`
CMD="cat $RunXML|xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -T -t -v \"/p:application/p:services/p:${modxmlPath}[@name='${parName}']/p:bindings/p:binding[@name='${instName}']/p:NVPairs\""
echo $CMD > /tmp/check$$.sh
check=`sh /tmp/check$$.sh`
rm -f  /tmp/check$$.sh
if [ -z "$check" ]; then
	echo "creating NVPairs node"
	echo "[`date`]::INFO::Creating NVPairs node" >> ${MAIL_LOG}
	echo "cat $RunXML | xml ed -N p=http://www.tibco.com/xmlns/ApplicationManagement -s \"/p:application/p:services/p:${modxmlPath}[@name='${parName}']/p:bindings/p:binding[@name='${instName}']\" --type elem -n NVPairs -v \"\" > ${RunXML}\".tmp1\"" > /tmp/temp1$$.sh
	sh /tmp/temp1$$.sh
	echo "[`date`]::INFO::Adding attribute name to NVPairs node" >> ${MAIL_LOG}
	echo "cat ${RunXML}\".tmp1\" | xml ed -N p=http://www.tibco.com/xmlns/ApplicationManagement -s \"/p:application/p:services/p:${modxmlPath}[@name='${parName}']/p:bindings/p:binding[@name='${instName}']/p:NVPairs\" --type attr -n name -v \"Runtime Variables\" > ${RunXML}\".tmp\"" > /tmp/temp1$$.sh
	sh /tmp/temp1$$.sh
	if [ $? -eq 0 ]; then
		mv ${RunXML}".tmp" ${RunXML}
		 echo "[`date`]::INFO::NVPairs node created successfully" >> ${MAIL_LOG}
	else
		 echo "[`date`]::Error:Error creating NVPairs node" >> ${MAIL_LOG}
	fi
fi

CMD="cat $RunXML | xml ed -N p=http://www.tibco.com/xmlns/ApplicationManagement -s \"/p:application/p:services/p:${modxmlPath}[@name='${parName}']/p:bindings/p:binding[@name='${instName}']/p:NVPairs\" --type elem -n ResourceTMP -v \"\" -s \"/p:application/p:services/p:${modxmlPath}[@name='${parName}']/p:bindings/p:binding[@name='${instName}']/p:NVPairs/ResourceTMP\" --type elem -n name -v ${NVPairsName} -s \"/p:application/p:services/p:${modxmlPath}[@name='${parName}']/p:bindings/p:binding[@name='${instName}']/p:NVPairs/ResourceTMP\" --type elem -n value -v \"${attValue}\" -r \"/p:application/p:services/p:${modxmlPath}[@name='${parName}']/p:bindings/p:binding[@name='${instName}']/p:NVPairs/ResourceTMP\" -v \"NameValuePair\" | xml fo > ${RunXML}\".tmp\""
echo $CMD > /tmp/check$$.sh
sh /tmp/check$$.sh
	
if [ $? -eq 0 ]; then
        mv ${RunXML}".tmp" ${RunXML}
        echo "NameValuePair ${NVPairsName} created Successfully" >> ${UserInput}".success"
        echo 'CNG~valid~BD~'${attPar} >> ${MAIL_LOG}
else
        echo 'CNG~invalid~BD~'${attPar} >> ${MAIL_LOG}
fi


rm -f /tmp/check$$.sh
else
echo "attPar instName parName attName attPath : $attPar $instName $parName $attName $attPath"
CMD="cat $RunXML|xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -T -t -v \"/p:application/p:services/p:${modxmlPath}[@name='${parName}']/p:bindings/p:binding[@name='${instName}']/p:${attPath}/p:${attName}\""
echo $CMD > /tmp/check$$.sh
check=`sh /tmp/check$$.sh`
rm -f  /tmp/check$$.sh
if [ -z "$attValue" ]; then
	if [ ! -z "$check" ]; then
	cat $RunXML | xml ed -N p=http://www.tibco.com/xmlns/ApplicationManagement -d "/p:application/p:services/p:${modxmlPath}[@name='${parName}']/p:bindings/p:binding[@name='${instName}']/p:${attPath}/p:${attName}" > ${RunXML}".tmp"
if [ $? -eq 0 ]; then
	mv ${RunXML}".tmp" ${RunXML}
	echo "Node ${attTmpPar} Removed Successfully" >> ${UserInput}".success"
	echo 'CNG~valid~BD~'${attPar} >> ${MAIL_LOG}
else
	echo 'CNG~invalid~BD~'${attPar} >> ${MAIL_LOG}
fi
	fi

elif [  -z "$check" ]; then
	if [ ! -z "$attValue" ]; then
        echo "Resource not exists.. Creating"
	
	allNode=`echo $tmp2Path | sed 's/\// /g'`
	for node in $allNode; do
		isNodeAva=`checkNode $node`

		if [ "$isNodeAva" == "valid" ]; then
		crePath=$crePath"/p:"$node
		echo $crePath
		CMD="cat $RunXML|xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -T -t -v \"/p:application/p:services/p:${modxmlPath}[@name='${parName}']/p:bindings/p:binding[@name='${instName}']${crePath}\""
		echo $CMD > /tmp/check$$.sh
		check=`sh /tmp/check$$.sh`
		if [ -z "$check" ]; then
			echo "Node $node not exist"
			crePath1=`echo $crePath | awk -F "/p:${node}" '{ print $1 }'`
			CMD="cat $RunXML | xml ed -N p=http://www.tibco.com/xmlns/ApplicationManagement -s \"/p:application/p:services/p:${modxmlPath}[@name='${parName}']/p:bindings/p:binding[@name='${instName}']${crePath1}\" --type elem -n ${node} -v \"\"  > ${RunXML}.new"
        		echo $CMD > /tmp/temp1$$.sh
			sh /tmp/temp1$$.sh
			if [ $? -eq 0 ]; then
			mv ${RunXML}.new ${RunXML}
			echo 'CNG~valid~BD~'${attPar} >> ${MAIL_LOG}
			else
			echo 'CNG~invalid~BD~'${attPar} >> ${MAIL_LOG}
			fi
		fi
		else
		echo "Invalid Node $attTmpPar $attValue " >> $UserInput".failed"
		echo 'CNG~invalid~BD~'${attPar} >> ${MAIL_LOG}
		fi
	done
	isNodeAva=`checkNode ${attName}`
	if [ "$isNodeAva" == "valid" ]; then
        echo "cat $RunXML | xml ed -N p=http://www.tibco.com/xmlns/ApplicationManagement -s \"/p:application/p:services/p:${modxmlPath}[@name='${parName}']/p:bindings/p:binding[@name='${instName}']/p:${attPath}\" --type elem -n ${attName} -v ${attValue} > ${RunXML}.new" > /tmp/temp1$$.sh
        sh /tmp/temp1$$.sh
        if [ $? -eq 0 ]; then
                echo "Attribute created successfully for $attTmpPar $attValue" >> ${UserInput}".success"
		echo 'CNG~valid~BD~'${attPar} >> ${MAIL_LOG}
                mv ${RunXML}.new ${RunXML}
        else
                echo "Creation failed"
		echo 'CNG~invalid~BD~'${attPar} >> ${MAIL_LOG}
        fi
	else
	echo "Invalid Node $attTmpPar $attValue " >> $UserInput".failed"
	echo 'CNG~invalid~BD~'${attPar} >> ${MAIL_LOG}
	fi
	fi
else
        echo "Resource exist"
        echo "cat $RunXML | xml ed -P -S -N p=http://www.tibco.com/xmlns/ApplicationManagement  -u \"/p:application/p:services/p:${modxmlPath}[@name='${parName}']/p:bindings/p:binding[@name='${instName}']/p:${attPath}/p:${attName}\" -v '${attValue}'  > ${RunXML}.new" > /tmp/temp1$$.sh
        sh /tmp/temp1$$.sh
        if [ $? -eq 0 ]; then
                echo "updated successfully for $attTmpPar $attValue" >> ${UserInput}".success"
		echo 'CNG~valid~BD~'${attPar} >> ${MAIL_LOG}
                mv ${RunXML}.new ${RunXML}
        else
                echo "update failed $attTmpPar $attValue" >> $UserInput".failed"
		echo 'CNG~invalid~BD~'${attPar} >> ${MAIL_LOG}
        fi


fi
fi
done
fi
done

cat $UserInput | grep -v "^$" | grep "PV~" | while IFS= read -r thisVal
do
pvAttr=`echo $thisVal | awk -F\~ '{ print $2 }' | awk -F\= '{ print $1 }'`
pvValue=`echo $thisVal | awk -F\~ '{ print $2 }' | awk -F\= '{ print $2 }'`
pvParName=`echo $pvAttr | awk -F\/ '{ print $1 }'`
pvAttName=`echo $pvAttr | rev| awk -F\/ '{ print $1 }'|rev`
pvName=`echo $pvAttr | awk -F "${pvParName}/"  '{ print $2 }' | awk -F "/${pvAttName}" '{ print $1 }'`

CMD="cat $RunXML|xml sel -N p=http://www.tibco.com/xmlns/ApplicationManagement -T -t -v \"/p:application/p:services/p:bw[@name='${pvParName}']/p:bwprocesses/p:bwprocess[@name='${pvName}']/p:${pvAttName}\""
echo $CMD > /tmp/check$$.sh
echo $CMD
check=`sh /tmp/check$$.sh`

if [  -z "$check" ]; then
        echo "Resource not exists.."
else
        echo "Resource exist"
        echo "cat $RunXML | xml ed -P -S -N p=http://www.tibco.com/xmlns/ApplicationManagement  -u \"/p:application/p:services/p:bw[@name='${pvParName}']/p:bwprocesses/p:bwprocess[@name='${pvName}']/p:${pvAttName}\" -v '${pvValue}'  > ${RunXML}.new" > /tmp/temp1$$.sh
        sh /tmp/temp1$$.sh
        if [ $? -eq 0 ]; then
                echo "updated successfully for $pvAttr $pvValue" >> ${UserInput}".success"
                echo 'CNG~valid~PV~'${pvAttr} >> ${MAIL_LOG}
                mv ${RunXML}.new ${RunXML}
        else
                echo "update failed $pvAttr $pvValue" >> $UserInput".failed"
                echo 'CNG~invalid~PV~'${pvAttr} >> ${MAIL_LOG}
        fi
fi

done

isSuccess=`cat ${UserInput}".success"`
if [ ! "$isSuccess" == "" ]; then
echo -e "\n---------------------------------------------------VALID Changes----------------------------------------------\n"
cat ${UserInput}".success" | while IFS='\=' read successValue1 successValue2;
        do
                echo $successValue1
        done
echo -e "----------------------------------------------------------------------------------------------------------------\n"
else
echo -e "--------------------------------------------------VALID Changes--------------------------------------------------\n"
echo -e "NIL"
echo -e "------------------------------------------------------------------------------------------------------------------\n"
fi
rm -f ${UserInput}".success"

isFailed=`cat ${UserInput}".failed"`
if [ ! "$isFailed" == "" ]; then
echo -e "------------------------------------------------INVALID Changes----------------------------------------------------\n"
cat $UserInput".failed" | while IFS='\=' read failedValue1 failedValue2;
        do
                echo $failedValue1
        done
echo -e "--------------------------------------------------------------------------------------------------------------------\n"
else
echo -e "------------------------------------------------INVALID Changes------------------------------------------------------\n"
echo -e "NIL"
echo -e "----------------------------------------------------------------------------------------------------------------------\n"
fi
rm -f $UserInput".failed"
