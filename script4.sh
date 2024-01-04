#!/bin/bash
if [ $# -eq 2 ] && [ ${#2} -eq 10 ] ; then
    choix1="Afficher la totalité des erreurs pour une journée"
    choix2="Afficher la totalité des erreurs sous forme de fichier .imp pour une journée"
    choix3="Afficher le nombre d’erreurs sur une journée"
    choix4="Afficher les nombres de type d’erreurs différents correspondant dans une journée"
    choix5="Afficher en saisissant une adresse IP, avoir les erreurs en totalité de cette adresse IP"
    choix6="Afficher en saisissant un pid (process), avoir toutes les erreurs correspondantes"
    choix7="Afficher en saisissant un type d’erreur, afficher les différents messages d’erreur correspondants"
    jour=${2:0:2} #on extracte du deuxieme argument le jour
    mois=${2:3:2} #on extracte du deuxieme argument le mois
    annee=${2:6:4} #on extracte du deuxieme argument l'année
    menu=("$choix1" "$choix2" "$choix3" "$choix4" "$choix5" "$choix6" "$choix7" "quitter") #liste des choix possible du menu
    echo "Journée : $jour/$mois/$annee"
    echo "Choisissez l'option que vous voulez :"
    select choix in "${menu[@]}" #on affiche le menu et on demande de choisir une option
        do
            case $choix in #cas parmi
                "$choix1")
                    while read -r line; do
                      erreur=$(echo "$line" | column -t | sed 's@\[[^]]*\]@@')
                      echo "Le $jour/$mois/$annee :$erreur"
                    done < $1/$annee/$mois/$jour"_error.log"
                    ;;
                "$choix2")
                    if [ -d "sortie" ]; then
                        echo "$(whoami) , le repertoire 'sortie' existe deja"
                    else
                        mkdir 'sortie'
                        echo "$(whoami) , le repertoire 'sortie' a eté crée"
                    fi
                    nom_fichier=$jour"_"$mois"_"$annee"_sortie.imp"
                    while read -r line; do
                      erreur=$(echo "$line" | column -t | sed 's@\[[^]]*\]@@')
                      echo "Le $jour/$mois/$annee :$erreur" >> "sortie/$nom_fichier"
                    done < $1/$annee/$mois/$jour"_error.log"
                    ;;
                "$choix3")
                    erreurs=$(cut -d "[" -f3 $1/$annee/$mois/$jour"_error.log" | cut -d "]" -f1 | wc -l) #nombre des lignes = nombre des erreurs
                    echo "Nombre d'erreurs : $erreurs"
                    ;;
                "$choix4")
                    type_err=$(cut -d "[" -f3 $1/$annee/$mois/$jour"_error.log" | sort | uniq | cut -d "]" -f1 | wc -l) #le type d'erreurs se trouve dans le deuxieme [], on le trie et on enleve les doublons et apres on le compte
                    echo "Nombre de types d'erreurs : $type_err"
                    ;;
                "$choix5")
                    echo "Saisir une addresse IP : "
                    read adresse_saisie #lire la saisie et la sauvegarder dans adresse_saisie
                    while read -r line; do #on lit chaque ligne du fichier
                      client_ligne=$(echo "$line" | cut -d "[" -f5 | cut -d "]" -f1)
                      adresse_ligne=$(echo ${client_ligne:7:18} | cut -d ":" -f1)
                      if [ $adresse_saisie == $adresse_ligne ]; then #si l'adresse saisie et l'adresse de la ligne sont egaux on affichera l'adresse de la ligne
                        echo $line
                      fi
                    done < $1/$annee/$mois/$jour"_error.log"
                    ;;
                "$choix6")
                    echo "Saisir un pid : "
                    read pid_saisie
                    while read -r line; do
                      pid_ligne=$(echo "$line" | cut -d "[" -f4 | cut -d "]" -f1)
                      num_pid_ligne=${pid_ligne:4:${#pid_ligne}}
                      if [ $pid_saisie -eq $num_pid_ligne ]; then #meme raisonnement de la choix 5 mais avec le pid
                        echo $line
                      fi
                    done < $1/$annee/$mois/$jour"_error.log"
                    ;;
                "$choix7")
                    echo "Saisir un type d'erreur" #il faut saisir l'erreur complet, par exemple core:crit ou core:error ou php7:error
                    read err_saisie
                    while read -r line; do #meme raisonnement de la choix 5 mais avec le type d'erreur
                      type_err=$(echo "$line" | cut -d "[" -f3 | cut -d "]" -f1)
                      if [ $err_saisie == $type_err ]; then
                        echo $line
                      fi
                    done < $1/$annee/$mois/$jour"_error.log"
                    ;;
                "quitter")
                    break
                    ;;
                *) echo "choix invalide";; #si la choix saisie est invalide
            esac
        done
else
	echo "Il doit y avoir un repertoire et une date comme arguments"
	echo "usage : ./script4.sh repertoire jj/mm/aaaa"
fi
exit