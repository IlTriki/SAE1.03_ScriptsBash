#!/bin/bash
if [ $# -eq 2 ] && [ ${#2} -eq 7 ]; then
    choix1="Afficher la totalité des erreurs pour un mois"
    choix2="Afficher la totalité des erreurs sous forme de fichier .imp pour un mois"
    choix3="Afficher le nombre d’erreurs sur un mois"
    choix4="Afficher les nombres de type d’erreurs différents correspondant dans un mois"
    choix5="Afficher en saisissant une adresse IP, avoir les erreurs en totalité de cette adresse IP"
    choix6="Afficher en saisissant un pid (process), avoir toutes les erreurs correspondantes"
    choix7="Afficher en saisissant un type d’erreur, afficher les différents messages d’erreur correspondants"
    mois=${2:0:2}
    annee=${2:3:4}
    menu=("$choix1" "$choix2" "$choix3" "$choix4" "$choix5" "$choix6" "$choix7" "quitter")
    echo "Mois : $mois/$annee"
    echo "Choisissez l'option que vous voulez :"
    select choix in "${menu[@]}"
        do
            case $choix in 
                "$choix1")
                    cd $1/$annee/$mois
                    for i in *error.log; do #boucle for pour regarder tout les fichiers error.log
                        echo "$i :"
                        echo ""
                        while read -r line; do
                          erreur=$(echo "$line" | column -t | sed 's@\[[^]]*\]@@')
                          echo "Le ${i:0:2}/$mois/$annee :$erreur" | sed 's/[,]//g' | sed 's/[=[]//g' | sed 's/[]]//g'
                        done < $i
                        echo ""
                    done
                    cd ..; cd ..; cd ..
                    ;;
                "$choix2")
                    if [ -d "sortie" ]; then #si le dossier n'existe pas on va le creer
                        echo "$(whoami) , le repertoire 'sortie' existe deja"
                    else
                        mkdir 'sortie'
                        echo "$(whoami) , le repertoire 'sortie' a eté crée"
                    fi
                    nom_fichier=$mois"_"$annee"_sortie.imp"
                    cd $1/$annee/$mois
                    for i in *error.log; do
                        cd ..; cd ..; cd ..
                        echo "$i :" >> "sortie/$nom_fichier" #dans le fichier sortie on va mettre le nom du fichier log qu'on est en train de parcourir
                        
                        cd $1/$annee/$mois
                        while read -r line; do
                          erreur=$(echo "$line" | sed 's@\[[^]]*\]@@')
                          cd ..; cd ..; cd ..
                          echo "Le ${i:0:2}/$mois/$annee :$erreur" >> "sortie/$nom_fichier" #on ecrit dans le fichier les erreurs
                          cd $1/$annee/$mois
                        done < $i
                    done
                    echo "le fichier $nom_fichier a été crée dans le dossier 'sortie'"
                    cd ..; cd ..; cd ..
                    ;;
                "$choix3")
                    cd $1/$annee/$mois
                    err_tot=0
                    for i in *error.log; do
                        erreurs=$(cut -d "[" -f3 $i | cut -d "]" -f1 | wc -l) #variable qui contient le nombre des erreurs d'un fichier
                        err_tot=$(expr $err_tot + $erreurs) #variable pour le totale
                    done
                    cd ..; cd ..; cd ..  
                    echo "Nombre d'erreurs : $err_tot"
                    ;;
                "$choix4")
                    cd $1/$annee/$mois
                    type_tot=""
                    for i in *error.log; do
                        type_err=$(cut -d "[" -f3 $i | sort | uniq | cut -d "]" -f1)
                        type_tot=$(echo -e "$type_tot\n$type_err") #meme raisonnement que la choix 3 mais avec les types d'erreurs
                    done
                    cd ..; cd ..; cd ..
                    type_tot=$(echo "$type_tot" | sort | uniq | wc -l)
                    echo "Nombre de types d'erreurs : $(expr $type_tot - 1)"
                    ;;
                "$choix5")
                    echo "Saisir une adresse IP : "
                    read addresse_saisie
                    cd $1/$annee/$mois
                    for i in *error.log; do
                      while read -r line; do
                        client_ligne=$(echo "$line" | cut -d "[" -f5 | cut -d "]" -f1)
                        addresse_ligne=$(echo ${client_ligne:7:18} | cut -d ":" -f1)
                        if [ $addresse_saisie == $addresse_ligne ]; then
                           echo $line
                        fi
                      done < $i 
                    done
                    cd ..; cd ..; cd ..  
                    ;;
                "$choix6")
                    echo "Saisir un pid : "
                    read pid_saisie
                    cd $1/$annee/$mois
                    for i in *error.log; do
                      while read -r line; do
                        pid_ligne=$(echo "$line" | cut -d "[" -f4 | cut -d "]" -f1)
                        num_pid_ligne=${pid_ligne:4:${#pid_ligne}}
                        if [ "$pid_saisie" == "$num_pid_ligne" ]; then
                          echo $line
                        fi
                      done < $i
                    done
                    cd ..; cd ..; cd ..
                    ;;
                "$choix7")
                    echo "Saisir un type d'erreur"
                    read err_saisie
                    cd $1/$annee/$mois
                    for i in *error.log; do
                      while read -r line; do
                        type_err=$(echo "$line" | cut -d "[" -f3 | cut -d "]" -f1)
                        if [ $err_saisie == $type_err ]; then
                          echo $line
                        fi
                      done < $i
                    done
                    ;;
                "quitter")
                    break
                    ;;
                *) echo "choix invalide";;
            esac
        done
else
	echo "Il doit y avoir un repertoire et une date (seulement le mois et l'année) comme arguments"
	echo "usage : ./script5.sh repertoire mm/aaaa"
fi
exit