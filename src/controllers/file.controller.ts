import { Post, Get, Route, Security, Response, Request } from 'tsoa';
import * as express from 'express';
import * as multer from 'multer';
import * as path from 'path';
import * as fs from 'fs';
import * as shell from 'shelljs';

@Route('files')
export class FilesController {
  wSubfolder: string;
  static wSubfolderStatic: string;
  constructor() {
    this.wSubfolder = "defaultSubfolderOne";
    this.handleFile = this.handleFile.bind(this);
  }
  // https://scotch.io/tutorials/express-file-uploads-with-multer
  // https://stackabuse.com/handling-file-uploads-in-node-js-with-expres-and-multer/
  // https://symmetrycode.com/super-easy-image-uploads-with-multer-and-express/
  @Post('uploadFile')
  public async uploadFile(@Request() request: express.Request): Promise<any> {

    let pokusStorageOnDisk = await this.handleFile(request, request.body.cheminRepoGitFichierSousEdition);
    // file will be in request.fichierSousEdition, it is a buffer
    console.log ('J ai invoque le endpoint upload file');
    let cheminFichierDansGitRepoPre = request.body.cheminRepoGitFichierSousEdition;
    let cheminFichierDansGitRepo = cheminFichierDansGitRepoPre.replace(/"/g,'');
    let cheminCOMPLETFichierDansGitRepo = process.env.POKUS_GITOPS + '/' + cheminFichierDansGitRepo;
    let cheminCOMPLETFichierUpload = process.env.POKUS_UPLOADS + '/' + cheminFichierDansGitRepo.split('/').pop();

    let repertoireSplits = cheminFichierDansGitRepo.split('/');
    let repertoire = repertoireSplits.splice(0, (repertoireSplits.length - 1));

    let cheminCOMPLETRepertoireDansGitRepo = process.env.POKUS_GITOPS + '/' + repertoire.join('/');
    console.log(" Valeur [cheminCOMPLETFichierDansGitRepo] = [" + cheminCOMPLETFichierDansGitRepo + "]");
    console.log(" Valeur [cheminCOMPLETFichierUpload] = [" + cheminCOMPLETFichierUpload + "]");
    console.log(" Valeur [cheminCOMPLETRepertoireDansGitRepo] = [" + cheminCOMPLETRepertoireDansGitRepo + "]");
    // on créée le répêrtoire [cheminCOMPLETRepertoireDansGitRepo] s'il n'existe pas
    // Run external tool synchronously
    if (shell.exec("mkdir -p " + cheminCOMPLETRepertoireDansGitRepo).code !== 0) {
      shell.echo("Error creating folder [" + cheminCOMPLETRepertoireDansGitRepo + "]");
      shell.exit(1);
    }
    // [cheminCOMPLETFichierDansGitRepo] will be created or overwritten by default.
    if (shell.exec("cp -f " + cheminCOMPLETFichierUpload + " " + cheminCOMPLETFichierDansGitRepo).code !== 0) {
      shell.echo("Error copying file [" + cheminCOMPLETFichierUpload + "] to [" + cheminCOMPLETFichierDansGitRepo + "]");
      shell.exit(1);
    }

    // now let's git commit and push... ? (assumes you have a working private key / public key pair with public key registered on the github/gitlab account )

    if (shell.exec("cd " + process.env.POKUS_GITOPS + " && git add --all && git commit -m 'pokus just commited ' && git push -u origin master").code !== 0) {
      // shell.echo("Error git commit n pushing file [" + cheminCOMPLETFichierUpload + "] in [" + process.env.POKUS_GITOPS + "]");
      console.log("Error git commit n pushing file [" + cheminCOMPLETFichierUpload + "] in [" + process.env.POKUS_GITOPS + "]");
      // shell.exit(1);
    }
    /**/

    console.log( "  Valeur de [process.env.POKUS_WKSP] = [" + process.env.POKUS_WKSP + "]");
    console.log( "  Valeur de [process.env.POKUS_UPLOADS] = [" + process.env.POKUS_UPLOADS + "]");
    console.log( "  Valeur de [process.env.POKUS_GITOPS] = [" + process.env.POKUS_GITOPS + "]");
    return { msg: 'J ai invoque le endpoint upload file', cheminFichierDansGitRepo: cheminFichierDansGitRepo };
  }

  private handleFile(request: express.Request, subfolder: string): Promise<any> {

    const pokusStorageOnDisk = multer.diskStorage({
      destination: function(req, file, cb) {
        //console.log(" [multer.diskStorage#destination] Valeur req.body : [" + req.body + "]");
        // console.log(" [multer.diskStorage#destination] Valeur req.session : [" + req.session + "]");
          // le repertoire [process.Env.POKUS_UPLOADS] doit exister
          console.log(" ++ [" + process.env.POKUS_UPLOADS + "] decide du chemin du workspace par config : ");
          cb(null, process.env.POKUS_UPLOADS);
      },

      // By default, multer removes file extensions so let's add them back
      filename: function(req, file, cb) {
        // console.log(" [multer.diskStorage#filename] Valeur generee : [" + file.fieldname + '-' + Date.now() + path.extname(file.originalname) + "]");
        // console.log(" [multer.diskStorage#filename] Valeur file.originalname : [" + file.originalname + "]");
        // console.log(" [multer.diskStorage#filename] Valeur path.extname(file.originalname) : [" + path.extname(file.originalname) + "]");
        cb(null, file.originalname);
      }
    });
    // The main multer object
    const pokusSingleMulter = multer({
      storage: pokusStorageOnDisk
    }).single('fichierSousEdition');
    //console.log(" TEST DU MULTER SINGLE TRAITE : [" + multerSingle + "]")
    return new Promise((resolve, reject) => {
      pokusSingleMulter(request, undefined, async (error) => {
        if (error) {
          reject(error);
        }
        resolve();
      });
    });
  }


  // loadTextFileToIDE

  /**
    *
    * Get file content by file path in git repo
    *
    * J'ai testé cette requêyte qui amrche dans firefox:
    * [http://poste-devops-typique:3000/api/v1/files/loadtext/chemin=voyons%2Fvoir%2F%C3%A7a]
    * -----------------------------------------------------------
    * => après avoir créé le fichier en exécutant la commande :
    * [curl -L -X POST -F 'fichierSousEdition=@"./ptitestespace/autrefichier.pokus"'  -F 'cheminRepoGitFichierSousEdition="ptitestespace/rep1/rep2/reTTT/autrefichier.pokus"' http://$POKUS_API_HOSTNAME:$POKUS_API_PORT_NO/api/v1/files/uploadFile | jq .]
    * => on devra pouvoir charger le contenu texte de ce fichier avec :
    * [http://poste-devops-typique:3000/api/v1/files/loadtext/chemin=ptitestespace%2Frep1%2Frep2%2FreTTT%2Fautrefichier.pokus]
    *
    ***/



  @Get('/loadtext/{chemin}')
  public async loadTextFileToIDE(chemin: string): Promise<any> {
    console.log(" [loadtext] -> chemin = [" + chemin + "]");
    let cheminCOMPLETFichier = process.env.POKUS_UPLOADS + '/' + chemin.split('=').pop();
    let leTexte = fs.readFile(path.join(process.env.POKUS_UPLOADS + '/' + chemin.split('=').pop()), (err, data) => {
        if (err) throw err;
        console.log(data);
    })
    // Ici je dois juste charger le contenu texte du fichier
    return {
      msg: 'Réponse au Endpoint [/loadtext]',
      chemin: chemin,
      texte: leTexte
    };
  }
}
