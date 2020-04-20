

class Anotacao{
  int id;
  String titulo;
  String descricao;
  String data;

  Anotacao(this.titulo,this.descricao,this.data);

  //Metodo para receber um map e retornar um objeto
  Anotacao.fromMap(Map map){
       this.id = map["id"];
       this.titulo = map["titulo"];
       this.descricao = map["descricao"];
       this.data = map["data"];
  }

  Map toMap(){
    Map<String, dynamic> map ={
      "titulo" : this.titulo,
      "descricao" : this.descricao,
      "data" : this.data
    };

    //Verificar sem tem um Id, caso tenha, tem que ser retonado
    if(this.id !=null){
      map["id"] = this.id;
    }
    return map;
  }
}