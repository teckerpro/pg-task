#!/usr/bin/env bash

cp config.xml config-result.xml

#Получение списка имен ролей (многострочная строка)
names=$(xmlstarlet sel -t -v "/hudson/authorizationStrategy/roleMap/role/@name" config-result.xml 2> /dev/null)

#Формирование массива из многосточной строки
arrayKeys=()
while read -r line; do
   arrayKeys+=("$line")
done <<< "$names"


printf "\nChanged elements:\n"
for value in ${arrayKeys[@]}; do
    #Получение sid
    sid=$(xmlstarlet sel -t -v "//role[contains(@name, '$value')]//sid" config-result.xml 2> /dev/null)

    #Проверка первого символа role name, запись в файл и вывод на терминал
    if [[ ${value:0:1} =~ [a-z] ]]
    then
        xmlstarlet ed --inplace -u "//role[@name='$value']/@name" -v "${value^}" config-result.xml 2> /dev/null
        printf "Role: $value -> ${value^}\n"
    fi

    #Проверка первого символа sid, запись в файл и вывод на терминал
    if [[ ${sid:0:1} =~ [a-z] ]]
    then
        xmlstarlet ed --inplace -u "//role[contains(@name, '${value^}')]//sid" -v "${sid^}" config-result.xml 2> /dev/null
        printf "Sid: $sid -> ${sid^}\n"
    fi
done


#Вывод на терминал списка role name и соответствующего sid
printf "\nList of all target elements:\n"
for value in ${arrayKeys[@]}; do
    sid=$(xmlstarlet sel -t -v "//role[contains(@name, '${value^}')]//sid" config-result.xml 2> /dev/null)
    printf "${value^} | ${sid}\n"
done
