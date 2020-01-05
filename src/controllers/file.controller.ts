import { Post, Get, Route, Security, Response, Request } from 'tsoa';
import * as express from 'express';
import * as multer from 'multer';
import * as path from 'path';


@Route('files')
export class FilesController {

  // https://scotch.io/tutorials/express-file-uploads-with-multer
  // https://stackabuse.com/handling-file-uploads-in-node-js-with-expres-and-multer/
  @Post('uploadFile')
  public async uploadFile(@Request() request: express.Request): Promise<any> {
    let pokusStorageOnDisk = await this.handleFile(request);
    // file will be in request.fichierSousEdition, it is a buffer
    console.log ('J ai invoquÃ© le endpoint upload file');
    console.log ('J ai enregistré le fichier [' + pokusStorageOnDisk.file.originalname + ']');


    return { msg: 'J ai invoquÃ© le endpoint upload file'};
  }

  private handleFile(request: express.Request): Promise<any> {
    //console.log(" TEST DU FILE ds request [" + request.file + "]");
    const pokusStorageOnDisk = multer.diskStorage({
      destination: function(req, file, cb) {
          // le répertoire [workspace/pokus] doit exister
          cb(null, 'workspace/pokus');
      },

      // By default, multer removes file extensions so let's add them back
      filename: function(req, file, cb) {
        console.log(" Valeur chopee : [" + file.fieldname + '-' + Date.now() + path.extname(file.originalname) + "]");
        console.log(" Valeur file.originalname : [" + file.originalname + "]");
        console.log(" Valeur path.extname(file.originalname) : [" + path.extname(file.originalname) + "]");
        cb(null, file.fieldname + path.extname(file.originalname));
      }
    });
    // file will be in request.fichierSousEdition, it is a buffer
    const multerSingle = multer({ storage: pokusStorageOnDisk}).single('fichierSousEdition');
    //console.log(" TEST DU MULTER SINGLE TRAITÃ© : [" + multerSingle + "]")
    return new Promise((resolve, reject) => {
      multerSingle(request, undefined, async (error) => {
        if (error) {
          reject(error);
        }
        resolve();
      });
    });
  }
}
