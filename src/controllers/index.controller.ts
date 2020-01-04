import { Controller, Get, Route } from 'tsoa';

@Route('')
export class IndexController extends Controller {
    @Get('')
    public async index() {
        return { msg: 'Réponse au Endpoint "Racine", [/]!' };
    }

    @Get('/msg')
    public msg() {
        return { msg: 'Réponse au Endpoint Message, [/msg] :  Voici le message' };
    }
}
