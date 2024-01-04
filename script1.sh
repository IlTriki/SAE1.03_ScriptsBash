#!/bin/bash
if [ $# -eq 1 ] ; then #on verifie s'il y a un seul argument
	if [ -d $1 ] ; then #on verifie si l'argument donné est un dossier
		cd $1
        for i in *.log
            do
                if [ ${i:0:5} == "error" ]; then
                    nom="error.log"
                elif [ ${i:0:6} == "access" ]; then
                    nom="access.log"
                else
                    echo "Ce n'est pas un fichier access.log ou error.log"
                fi
                if [ $nom == "access.log" -o $nom == "error.log" ]; then
                    if [ $nom == "error.log" ]; then
                        jour="${i:6:2}_"
                        mois=${i:8:2}
                        annee="20${i:10:2}"
                    else
                        jour="${i:7:2}_"
                        mois=${i:9:2}
                        annee="20${i:11:2}"
                    fi
                    chemin_log="$annee/$mois/$jour"
                    if [ -d $annee ]; then
                        echo "$(whoami) , le repertoire $annee existe deja"
                    else
                        mkdir $annee
                        echo "$(whoami) , le repertoire $annee a eté crée"
                    fi
                    if [ -d "$annee/$mois" ]; then
                        echo "$(whoami) , le repertoire $mois existe deja dans le repertoire $annee"
                    else
                        mkdir "$annee/$mois"
                        echo "$(whoami) , le repertoire $mois a eté crée dans le repertoire $annee"
                    fi
                    cp "$i" $chemin_log$nom #on copie le fichier original dans le nouveau dossier sous le nouveau nom
                    echo "Le fichier $i a eté copié dans le repertoire '$annee/$mois' sous le nom '$jour$nom'"
                    > "$i" #on vide le fichier original de son contenu
                    echo "Le fichier $i a eté vidé de son contenu"
                fi
            done
    fi
else
	echo "Il doit y avoir 1 argument et il doit etre un repertoire"
	echo "usage : ./script1.sh repertoire"
fi
exit