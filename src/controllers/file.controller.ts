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
    await this.handleFile(request);
    // file will be in request.randomFileIsHere, it is a buffer
    console.log ('J ai invoquÃ© le endpoint upload file');
    return { msg: 'J ai invoquÃ© le endpoint upload file'};
  }

  private handleFile(request: express.Request): Promise<any> {
    const pokusStorageOnDisk = multer.diskStorage({
      destination: function(req, file, cb) {
          cb(null, 'worspace/pokus');
      },

      // By default, multer removes file extensions so let's add them back
      filename: function(req, file, cb) {
          cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
      }
    });

    const multerSingle = multer({ storage: pokusStorageOnDisk}).single('randomFileIsHere');
    console.log(" TEST DU MULTER SINGLE TRAITÃ© : [" + multerSingle + "]")
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
