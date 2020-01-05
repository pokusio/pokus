import { Post, Get, Route, Security, Response, Request } from 'tsoa';
import * as express from 'express';
import * as multer from 'multer';

@Route('files')
export class FilesController {

  // https://scotch.io/tutorials/express-file-uploads-with-multer
  @Post('uploadFile')
  public async uploadFile(@Request() request: express.Request): Promise<any> {
    await this.handleFile(request);
    // file will be in request.randomFileIsHere, it is a buffer
    console.log ('J ai invoqué le endpoint upload file');
    return { msg: 'J ai invoqué le endpoint upload file'};
  }

  private handleFile(request: express.Request): Promise<any> {
    const multerSingle = multer().single('randomFileIsHere');
    console.log(" TEST DU MULTER SINGLE TRAITé : [" + multerSingle + "]")
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
