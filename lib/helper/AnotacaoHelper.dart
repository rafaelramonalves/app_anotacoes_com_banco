import 'package:appanotacoescombanco/model/Anotacao.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//Classe que ficara responsável por manipular o banco de dados
///Classe utilizando o padrão Singleton, é retornado uma única instância
class AnotacaoHelper{

  static final String nomeTabela = "anotacao";

  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database _db;

  //Construtor padrão
  factory AnotacaoHelper(){
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal(){ //Um construtor nomeado
   }

   //Acessar banco de dados
   get db async{
    //Verificar se ja existe uma instância
    if(_db !=null){
      return _db;
    }else{
      _db = await inicializarDB();
      return _db;
    }

   }

   //Criar banco de dados
    _onCreate(Database db, int version) async{

      String sql="CREATE TABLE $nomeTabela "
          "("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "titulo VARCHAR,"
          "descricao TEXT,"//Campo text é maior que o varchar
          "data DATETIME"
          ")";
      await db.execute(sql);

    }


   inicializarDB() async{
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(
      caminhoBancoDados,
      "banco_minhas_anotacoes.db"
    );

    var db = await openDatabase(
      localBancoDados,
      version: 1,
      onCreate: _onCreate
    );
    return db;
   }

   Future<int> salvarAnotacao(Anotacao anotacao)async{

      var bancoDados = await _db;
      int resultado = await bancoDados.insert(
        nomeTabela,
        anotacao.toMap()
      );
      return resultado; //O id é retornado

   }

  recuperarAnotacoes() async{

    var bancoDados = await db;
    String sql ="SELECT * FROM $nomeTabela ORDER BY data DESC";
    List anotacoes = await bancoDados.rawQuery(sql);
    return anotacoes;

  }


  Future<int> atualizarAnotacao(Anotacao anotacao) async{

    var bancoDados = await db;

    //Atualizar dados do banco
    return await bancoDados.update( //Metodo retorna a quantidade de itens atualizados
      nomeTabela,
      anotacao.toMap(),
      where: "id = ?",
      whereArgs: [anotacao.id]
    );

  }

  Future<int> removerAnotacao(int id) async{
    var bancoDados = await db;
    return await bancoDados.delete(
      nomeTabela,
      where: "id = ?",
      whereArgs: [id]
    );

  }
}