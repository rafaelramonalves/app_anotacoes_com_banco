import 'package:appanotacoescombanco/helper/AnotacaoHelper.dart';
import 'package:appanotacoescombanco/model/Anotacao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController  _tituloController = TextEditingController();
  TextEditingController  _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> anotacoes = List<Anotacao>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarAnotacoes(); //Recuperar as anotações antes do programa iniciar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minha anotações"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: anotacoes.length,
                itemBuilder: (context,index){

                  final item = anotacoes[index];

                  return Card(
                    child: ListTile(
                      title: Text(item.titulo),
                      subtitle: Text("${_formatarData(item.data)} - ${item.descricao}"),
                      trailing: Row(//Widegt que será exibido do lado direito do card
                        mainAxisSize: MainAxisSize.min,//Row ocupar somente o necessário
                        children: <Widget>[

                          //Fazer edição
                          GestureDetector(
                            onTap: (){
                              _exibirTelaCadastro(anotacao: item);
                            },
                            child: Padding(
                            padding: EdgeInsets.only(right: 16),
                              child: Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                            ),
                          ),

                          //Fazer a remoção
                          GestureDetector(
                            onTap: (){
                              _removerAnotacao(item.id);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: (){
          _exibirTelaCadastro();
        },
      ),
    );
  }

  _exibirTelaCadastro( {Anotacao anotacao} ){ //{} parametros opcionais

    String textoSalvarAtualizar = "";

    //Saber se está atualizando ou salvando
    if(anotacao == null){//Salvando
    _tituloController.text = "";
    _descricaoController.text = "";
    textoSalvarAtualizar="Salvar";

    }else{//Atualizando
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      textoSalvarAtualizar="Atualizar";
    }
    showDialog(
        context: context,
      builder: (context){
          return AlertDialog(
            title: Text("$textoSalvarAtualizar anotação"),
            content: Column(
              ///Definir o tamanho do item que se está utilizando - o
              ///tamanho que ficará a chebox por exemplo
              mainAxisSize: MainAxisSize.min, //ocupar o minimo que se puder
              children: <Widget>[
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Título",
                    hintText: "Digite o título..."
                  ),
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                      labelText: "Descrição",
                      hintText: "Digite a descrição..."
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: ()=>Navigator.pop(context),
                child: Text("Cancelar"),
              ),
              FlatButton(
                onPressed: (){
                    _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                  Navigator.pop(context);
                },
                child: Text(textoSalvarAtualizar),
              ),
            ],
          );
      }
    );
  }

  _salvarAtualizarAnotacao({Anotacao anotacaoSelecionada})async{

    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if(anotacaoSelecionada == null){ //salvando
      Anotacao anotacao = Anotacao(titulo,descricao,DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);

    }else{ //Atualizando

      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
    }



    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacoes();

  }

  //Recuperar as anotações do banco de dados
  _recuperarAnotacoes()async{

    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao> listaTemporaria = List<Anotacao>();

    for(var item in anotacoesRecuperadas){
        Anotacao anotacao = Anotacao.fromMap(item);
        listaTemporaria.add(anotacao);
    }

    setState(() {
      anotacoes = listaTemporaria;
      listaTemporaria = null;
    });
    print("Lista anotações: ${anotacoesRecuperadas.toString()}");
  }

  //Colocar a data no padrão BR
  _formatarData(String data){

    initializeDateFormatting("pt_BR");

    //var formato = DateFormat("d/MM/y");

    var formato = DateFormat.yMMMMd("pt_BR");

    //Pegar a data que veio em String e tranformar no tipo DATE
    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formato.format(dataConvertida);

    return dataFormatada;
  }

  _removerAnotacao(int id) async{

    await _db.removerAnotacao(id);
    _recuperarAnotacoes();
  }
}
