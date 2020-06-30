## Architecture



## Specs

essayer ça : 
* Je reprends le code Angular 2 + hugo de https://gitlab.com/second-bureau/hypocrate/recherche/contrat-social/de_lexterieur/exemple-angular-hugo.git
* Je dois d'abord arriver à le déployer, refaire tou tle build from sosurce, et en même temps voir comment ça se mélange avec hugo : build et puis derrière je fais es hugo new pour ajouter du contenu

* une fois le mécanisme compris : 
  * imaginons je fais mon build et comme fireship.io , cad que le build angulmar déclenche le hugo build, puis fais le build angular
  * alors la question est si je fais hugo new, il y a deux ossibilité s : 
    * c'est du blue green, et en fait, pour voir qu'une page a été mise à jour, il faut recharger la page entière, l'appmiation angular
    * mais ça n'est pas possible à l'utilsatio :  non
* alors ce que je veux voir, c'est s'il est possible que je fasse l'édition pokus d'une (nouvelle) entrée `content`
* et quand j'ai terminé ma modification ,j'appuie sur "enregister/envoyer", une fois la réponse JSON reçue de l'API, confirmant  que le git commit n puhs a bien réussit, alors je fais le reload du composant affichant le résultat de l'édition, 
* relaod du composant au sens de https://stackoverflow.com/questions/47813927/how-to-refresh-a-component-in-angular  (dan scette référence j'ai même des solutions datant de 2020, et avec Angular 9

Objectif : Angular 9

D2jà si je suis ne angualr, ce sera déjà pas mal, je verrais si je peux avoir angular material

sinon il leur faut revealjs pour faire des présentations power pont en direct

cette webui sera la meêm spec pour pokus

architecture : 

![archi pokus](https://gitlab.com/second-bureau/pegasus/pokus/pokus/-/raw/master/documentations/images/impr.ecran/architecture/pokus-architecture.png?inline=false)