import { Post, Get, Route, Security, Response } from 'tsoa';
import * as express from 'express';
import * as multer from 'multer';

@Route('files')
export class FilesController {

  @Post('uploadFile')
  public async uploadFile(@Request() request: express.Request): Promise<any> {
    await this.handleFile(request);
    // file will be in request.randomFileIsHere, it is a buffer
    return {};
  }

  private handleFile(request: express.Request): Promise<any> {
    const multerSingle = multer().single('randomFileIsHere');
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
