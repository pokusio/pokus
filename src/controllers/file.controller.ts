import { Post, Get, Route, Security, Response, Request } from 'tsoa';
import * as express from 'express';
import * as multer from 'multer';
import * as path from 'path';


@Route('files')
export class FilesController {
  wSubfolder: string;
  static wSubfolderStatic: string;

  // https://scotch.io/tutorials/express-file-uploads-with-multer
  // https://stackabuse.com/handling-file-uploads-in-node-js-with-expres-and-multer/
  @Post('uploadFile')
  public async uploadFile(@Request() request: express.Request): Promise<any> {
    this.wSubfolder=request.body.cheminFichierSousEdition;
    FilesController.wSubfolderStatic=request.body.cheminFichierSousEdition;
    this.testOfMine(request);
    let pokusStorageOnDisk = await this.handleFile(request);
    // file will be in request.fichierSousEdition, it is a buffer
    console.log ('J ai invoque le endpoint upload file');
    console.log(" Valeur request.body.cheminFichierSousEdition : [" + request.body.cheminFichierSousEdition + "]");
    let machin = request.body.cheminFichierSousEdition;
    console.log(" Valeur machin : [" + machin + "]");
    console.log(" Valeur this.wSubfolder : [" + this.wSubfolder + "]");
    console.log(" Valeur FilesController.wSubfolderStatic : [" + FilesController.wSubfolderStatic + "]");
    // console.log ('J ai enregistrÃÂ© le fichier [' + pokusStorageOnDisk.file.originalname + ']');


    return { msg: 'J ai invoque le endpoint upload file'};
  }
  private testOfMine(request: express.Request): void {
    console.log(" [testOfMine] Valeur request.body.cheminFichierSousEdition : [" + request.body.cheminFichierSousEdition + "]");
    console.log(" [testOfMine] Valeur this.wSubfolder : [" + this.wSubfolder + "]");
  }
  private handleFile(request: express.Request): Promise<any> {
    //console.log(" TEST DU FILE ds request [" + request.file + "]");
    const theSubfolder = this.wSubfolder;
    console.log(" [handleFile] Valeur request.body.cheminFichierSousEdition : [" + request.body.cheminFichierSousEdition + "]");
    console.log(" [handleFile] Valeur theSubfolder : [" + theSubfolder + "]");

    const pokusStorageOnDisk = multer.diskStorage({
      destination: function(req, file, cb) {
          // le rÃÂ©pertoire [workspace/pokus] doit exister
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
      storage: pokusStorageOnDisk}
    ).single('fichierSousEdition');
    //console.log(" TEST DU MULTER SINGLE TRAITÃÂÃÂ© : [" + multerSingle + "]")
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
