#!/bin/bash

#OOMS AURELIEN
#BA2 INFO
#PROJET1 INFO-F-201
#2011-2012

#je n'ai pas mis de commentaires là où j'ai estimé que les echo étaient assez explicites

#CONSTANTES
SORTED16BYTESINDEX=2
SORTEDBYTEINDEX=$1
NUMBEROFSOURCES=$2
FIRSTPARAMETERINDEX=3
DIRECTORYREGEXP="/{0,1}([^/]+/)*([^/]*)"
PARAMETERSREGEXP='^((1[0-6])|([1-9]))[[:space:]][1-9][[:digit:]]*[[:space:]]('$DIRECTORYREGEXP'[[:space:]]){'$NUMBEROFSOURCES'}'$DIRECTORYREGEXP'$'
PARAMETERSPATTERN="\$SORTEDBYTEINDEX[1-16] \$NUMBEROFSOURCES[1-...] (\$SOURCE ){\$NUMBEROFSOURCES}\$OUTPUT"

#FONCTIONS
prepareOutputDirectory(){ #outputDirectory

    #création du dossier output demandé
    #(s'arrête si on n'a pas le droit d'y accéder)
    if mkdir -p "$1" && [ -w "$1" ]
    then
    
        #création des 256 dossiers nécessaires au tri
        #(c'est ce que j'ai cru comprendre à partir de l'énoncé, création automatique des 256 dossiers même si non utilisés)
        #(pas d'erreur affichée si l'un ou plusieurs d'entre eux existent déjà)
        J=0
        while [ $J -lt 256 ]
        do
            mkdir -p "$1"/$J
            J=$(($J+1))
        done   
        
        echo "J'ai préparé le dossier "$1" et les 256 sous-dossiers utilisés pour le tri"
        return 0

    else
        echo "Je n'ai pas le droit d'utiliser/créer le dossier "$1
        return 1
    fi

}

sortFile(){ #directory #sortedByte #file #output #sorted16BytesIndex

    #récupération des 16 octets parmis lesquels ont choisi l'octet de tri
    allBytes=$(echo $3 | cut -d "_" -f$5)

    #récupération de l'octet de tri
    sortedByteIndex=$(($(($2-1))*2))
    sortedByteHexValue=${allBytes:$sortedByteIndex:2}

    #conversion decimale
    let sortedByteDecValue=0x$sortedByteHexValue

    #copie du fichier
    if cp "$1"/$file "$4"/$sortedByteDecValue/$file
    
    then
        echo -e "J'ai copié le fichier "$file" dans le dossier "$4/$sortedByteDecValue

    else
        echo -e "Je n'ai pas pu copier le fichier "$file" dans le dossier "$4/$sortedByteDecValue

    fi
}

sortAllInputDirectoryFiles(){ #directory #sortedByte #output #sorted16BytesIndex
    echo ""
    for file in $(ls "$1")
    do          
        if [ -d "$1"/$file ]

        then
            echo -e "Je ne trie pas "$file" car c'est un dossier"

        elif ! echo $file | grep -E -q '^[[:digit:]A-F]{32}_[[:digit:]A-F]{32}_[[:digit:]A-F]{32}_[[:digit:]]+.txt$'

        then
            echo -e "Je ne vais pas trier le fichier "$file" parce qu'il ne correspond pas au type de fichier à trier"            

        else
            sortFile "$1" $2 $file "$3" $4
        fi
    done
}

#MAIN
    echo ""
    
    #teste si la syntaxe des paramètres est correcte
    if echo $@ | grep -E -q $PARAMETERSREGEXP
    
    then   

        lastParameterIndex=$(($NUMBEROFSOURCES+$FIRSTPARAMETERINDEX))

        outputDirectory=${@:$lastParameterIndex:1}

        if prepareOutputDirectory "$outputDirectory"

        then
            echo "Je vais trier le(s) dossier(s) "${@:$FIRSTPARAMETERINDEX:$NUMBEROFSOURCES}

            i=0
            while [ $i -lt $NUMBEROFSOURCES ]
            do
                directory=${@:$(($FIRSTPARAMETERINDEX+$i)):1}
                if [ -x "$directory" ]
                then
                    echo -e "Je commence à trier les fichiers contenus dans "$directory
                    sortAllInputDirectoryFiles "$directory" $SORTEDBYTEINDEX "$outputDirectory" $SORTED16BYTESINDEX
                    echo -e "J'ai fini de trier "$directory
                else
                    echo -e "Je ne vais pas pouvoir trier le dossier "$directory", je n'ai pas le droit d'y accéder"
                fi
                i=$(($i+1))
            done

            echo "J'ai fini de trier le(s) dossier(s) "${@:$FIRSTPARAMETERINDEX:$NUMBEROFSOURCES}

        else
            echo "Je n'ai pas pu créer ou ne peux pas utiliser le dossier "$outputDirectory" destiné à y placer les éléments triés, je m'arrête donc ici"
            
        fi

    else
        echo -e "\nLa syntaxe des paramètres est incorrecte, elle doit correspondre à :\n\n\t"$PARAMETERSPATTERN"\n"
    fi

    echo ""
