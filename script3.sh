
#!/bin/bash
if [ $# -eq 2 ] && [ ${#2} -eq 7 ] ; then
choix1="Après avoir saisi une adresse IP, on aura le nombre de requêtes différentes effectuées par
  cette adresse."
  choix2="Calculer le nombre de requêtes différentes, par heure de la journée."
  choix3="Après avoir saisi un nom d’utilisateur, calculer le nombre de code statut différent par
  utilisateur."
  choix4="Après avoir saisi un nom d’utilisateur, afficher toutes les IP différentes de             
  l’utilisateur."  
    mois=${2:0:2} #on extracte du deuxieme argument le mois
    annee=${2:3:4} #on extracte du deuxieme argument l'année
    menu=("$choix1" "$choix2" "$choix3" "$choix4" "quitter") #liste des choix possible du menu
    echo "Mois : $mois/$annee"
    echo "Choisissez l'option que vous voulez :"
    select choix in "${menu[@]}"
        do
            case $choix in 
                 "$choix1")
              cd $1/$annee/$mois
              echo "Saisir une adresse ip: "
              read adresse
              for i in *access.log; do
                requete=$(grep -c "$adresse" $i)
                requetes_tot=$(expr $requetes_tot + $requete)     
              done
              echo "Nombre de requetes : $requetes_tot"
              cd ..; cd ..; cd ..
            ;;
                  "$choix2")
              cd $1/$annee/$mois
              echo "La recherche peut prendre du temps, veuillez patienter"
              for heure in {0..23}; do
                  tot_heure=0
                  for i in *access.log; do
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
                    done < $i
                    echo "Il y a $tot_heure erreurs dans le fichier $i pour l'heure $heure"
                  done
                  echo "Il y a en total $tot_heure erreurs pour l'heure $heure"
              done
              cd ..; cd ..; cd ..
              ;;
                "$choix3")
              cd $1/$annee/$mois
              echo "Saisir un nom d'utilisateur: "
              read utilisateur
              for i in *access.log; do
                lignes=$(grep "$utilisateur" $i| awk '{print $8}' | sort -u |wc -l)
                requetes_tot=$(expr $requetes_tot + $lignes)
              done
              echo " Nombres des requetes : $requetes_tot"
              cd ..; cd ..; cd ..
            ;;
                "$choix4")
              cd $1/$annee/$mois
              echo "Saisir un nom d'utilisateur: "
              read utilisateur
              echo "La recherche peut prendre du temps, veuillez patienter"
              ad_tot=""
              for i in *access.log; do
                while read -r line; do
                  utilisateur_ligne=$(echo "$line" | cut -d "-" -f2 | cut -d "-" -f1)
                  if [ "$utilisateur_ligne" == "$utilisateur" ]; then
                    ad_ligne=$(echo $line | awk '{print $1}' | cut -d "-" -f1)
                    ad_tot=$(echo -e "$ad_tot\n$ad_ligne" | sort | uniq)
                  fi
                done < $i
              done
              cd ..; cd ..; cd ..
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
	echo "Il doit y avoir un repertoire et une date (seulement le mois et l'année) comme arguments"
	echo "usage : ./script3.sh repertoire mm/aaaa"
fi
exit
              
    
              
               
              
  
                
                
                