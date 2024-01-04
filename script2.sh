#!/bin/bash
if [ $# -eq 2 ] && [ ${#2} -eq 10 ] ; then
  choix1="Après avoir saisi une adresse IP, on aura le nombre de requêtes différentes effectuées par
  cette adresse."
  choix2="Calculer le nombre de requêtes différentes, par heure de la journée."
  choix3="Après avoir saisi un nom d’utilisateur, calculer le nombre de code statut différent par
  utilisateur."
  choix4="Après avoir saisi un nom d’utilisateur, afficher toutes les IP différentes de             
  l’utilisateur."
  jour=${2:0:2}
  mois=${2:3:2}
  annee=${2:6:4}

  menu=("$choix1" "$choix2" "$choix3" "$choix4" "quitter")
   echo "Journée : $jour/$mois/$annee"
  echo "Choisissez l'option que vous voulez :"
  select choix in "${menu[@]}"
      do
          case $choix in 
              "$choix1")
              echo "Saisir une adresse ip: "
              read adresse
              requete=$(grep -c "$adresse" $1/$annee/$mois/$jour"_access.log")
              echo "Nombre de requetes : $requete"
              ;;
              "$choix2")
              for heure in {0..23}; do
                tot_heure=0
                while read -r line; do
                  heure_ligne=$(echo $line | cut -d "[" -f2 | cut -d "]" -f1)
                  if [ "${heure_ligne:12:1}" == "0" ]; then
                    if [ "${heure_ligne:13:1}" == "$heure" ]; then
                      tot_heure=$(expr $tot_heure + 1)
                    fi
                  else
                    if [ "${heure_ligne:12:2}" == "$heure" ]; then
                      tot_heure=$(expr $tot_heure + 1)
                    fi
                  fi
                done < $1/$annee/$mois/$jour"_access.log"
                echo "Il y a $tot_heure erreurs pour l'heure $heure"
              done
              ;;
              "$choix3")
              echo "Saisir un nom d'utilisateur: "
              read utilisateur
              lignes=$(grep "$utilisateur" $1/$annee/$mois/$jour"_access.log" | awk '{print $8}' | sort -u |wc -l)
              echo " Nombres des requetes : $lignes"
             ;;
              "$choix4")
             echo "Saisir un nom d'utilisateur: "
              read utilisateur
              ad_tot=""
              while read -r line; do
                utilisateur_ligne=$(echo "$line" | cut -d "-" -f2 | cut -d "-" -f1)
                if [ "$utilisateur_ligne" == "$utilisateur" ]; then
                  ad_ligne=$(echo $line | awk '{print $1}' | cut -d "-" -f1)
                  ad_tot=$(echo -e "$ad_tot\n$ad_ligne" | sort | uniq)
                fi
              done < $1/$annee/$mois/$jour"_access.log"
              echo "Voici les differents adresses IP utilisés :"
              echo $ad_tot | tr ' ' '\n'
              ;;
              "quitter")
                    break
                    ;;
              *) echo "choix invalide";;
          esac
      done
else
	echo "Il doit y avoir un repertoire et une date comme arguments"
	echo "usage : ./script2.sh repertoire jj/mm/aaaa"
fi
exit
