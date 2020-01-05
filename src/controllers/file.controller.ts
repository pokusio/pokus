import { Post, Get, Route, Security, Response, Request } from 'tsoa';
import * as express from 'express';
import * as multer from 'multer';
import * as path from 'path';


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
    this.wSubfolder = request.body.cheminFichierSousEdition;
    let pokusStorageOnDisk = await this.handleFile(request, request.body.cheminFichierSousEdition);
    // file will be in request.fichierSousEdition, it is a buffer
    console.log ('J ai invoque le endpoint upload file');
    let repertoire = request.body.cheminFichierSousEdition;
    let fichier = request.body.fichierSousEdition;
    console.log(" Valeur request.body.cheminFichierSousEdition : [" + request.body.cheminFichierSousEdition + "]");
    this.testOfMine(request);
    return { msg: 'J ai invoque le endpoint upload file'};
  }

  private testOfMine(request: express.Request): void {
    console.log(" [testOfMine] Valeur request.body.cheminFichierSousEdition : [" + request.body.cheminFichierSousEdition + "]");
    console.log(" [testOfMine] Valeur FilesController.wSubfolderStatic : [" +  FilesController.wSubfolderStatic + "]");
  }

  private handleFile(request: express.Request, subfolder: string): Promise<any> {
    //console.log(" TEST DU FILE ds request [" + request.file + "]");
    const theSubfolder = this.wSubfolder;
    console.log(" [handleFile] Valeur request.body.cheminFichierSousEdition : [" + request.body.cheminFichierSousEdition + "]");
    console.log(" [handleFile] Valeur theSubfolder : [" + theSubfolder + "]");
    console.log(" [handleFile] Valeur du param subfolder : [" + subfolder + "]");


    const pokusStorageOnDisk = multer.diskStorage({
      destination: function(req, file, cb) {
        //console.log(" [multer.diskStorage#destination] Valeur req.body : [" + req.body + "]");
        // console.log(" [multer.diskStorage#destination] Valeur req.session : [" + req.session + "]");
          // le rÃÂÃÂ©pertoire [workspace/pokus] doit exister
          console.log(" ++ [" + workspacepath + "] Pour decider du chemin du workspace par config : ");
          cb(null, 'workspace/pokus');
      },

      // By default, multer removes file extensions so let's add them back
      filename: function(req, file, cb) {
        console.log(" [multer.diskStorage#filename] Valeur chopee : [" + file.fieldname + '-' + Date.now() + path.extname(file.originalname) + "]");
        console.log(" [multer.diskStorage#filename] Valeur file.originalname : [" + file.originalname + "]");
        // console.log(" Valeur [req.body.cheminFichierSousEdition] : [" + req.body.cheminFichierSousEdition + "]");
        console.log(" [multer.diskStorage#filename] Valeur path.extname(file.originalname) : [" + path.extname(file.originalname) + "]");
        console.log(" [multer.diskStorage#filename] Valeur du SUBFOLDER this.wSubfolder : [" + this.wSubfolder + "]")
        console.log(" [multer.diskStorage#filename] Valeur du SUBFOLDER [FilesController.wSubfolderStatic] : [" + FilesController.wSubfolderStatic + "]")
        cb(null, "subfolder1/" + file.originalname);
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
}
