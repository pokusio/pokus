import { Post, Get, Route, Security, Response, Request } from 'tsoa';
import * as express from 'express';
import * as multer from 'multer';
import * as path from 'path';


@Route('files')
export class FilesController {
  wSubfolder: string;
  // https://scotch.io/tutorials/express-file-uploads-with-multer
  // https://stackabuse.com/handling-file-uploads-in-node-js-with-expres-and-multer/
  @Post('uploadFile')
  public async uploadFile(@Request() request: express.Request): Promise<any> {
    this.wSubfolder=request.body.cheminFichierSousEdition;
    let pokusStorageOnDisk = await this.handleFile(request);
    // file will be in request.fichierSousEdition, it is a buffer
    console.log ('J ai invoque le endpoint upload file');
    console.log(" Valeur request.body.cheminFichierSousEdition : [" + request.body.cheminFichierSousEdition + "]");
    // console.log ('J ai enregistrÃÂ© le fichier [' + pokusStorageOnDisk.file.originalname + ']');


    return { msg: 'J ai invoquÃÂÃÂ© le endpoint upload file'};
  }

  private handleFile(request: express.Request): Promise<any> {
    //console.log(" TEST DU FILE ds request [" + request.file + "]");
    const pokusStorageOnDisk = multer.diskStorage({
      destination: function(req, file, cb) {
          // le rÃÂ©pertoire [workspace/pokus] doit exister
          cb(null, 'workspace/pokus');
      },

      // By default, multer removes file extensions so let's add them back
      filename: function(req, file, cb) {
        console.log(" Valeur chopee : [" + file.fieldname + '-' + Date.now() + path.extname(file.originalname) + "]");
        console.log(" Valeur file.originalname : [" + file.originalname + "]");
        console.log(" Valeur file.path : [" + file.path + "]");
        console.log(" Valeur path.extname(file.originalname) : [" + path.extname(file.originalname) + "]");
        console.log(" Valeur du SUBFOLDER this.wSubfolder : [" + this.wSubfolder + "]")
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
