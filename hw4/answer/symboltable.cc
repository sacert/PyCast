
#include <string>
#include <map>
#include <list>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include <stdexcept>
#include <iterator>
#include <algorithm>
#include <iostream>

using namespace std;

class symboltable {

public:

  symboltable() {
  }

  void new_symtbl() {
    symbol_table *new_symtbl = new symbol_table();
    symtbl.push_front(new_symtbl);
  }

  void pop_symtbl() {
    if (symtbl.empty())
      throw runtime_error("no symbol table to remove here!");
    symtbl.pop_front();
  }

  void remove_symtbl() {
    symbol_table *tbl;
    if (symtbl.empty())
      throw runtime_error("no symbol table to remove here!");
    else
      tbl = symtbl.front();
	tbl->clear();
	delete(tbl);
    symtbl.pop_front();
  }

  void enter_symtbl(string ident, descriptor *d) {
    symbol_table *tbl;
    symbol_table::iterator find_ident;

    if (symtbl.empty())
      throw runtime_error("no symbol table created yet!");

    tbl = symtbl.front();
    if ((find_ident = tbl->find(ident)) != tbl->end()) {
      cerr << "Warning: redefining previously defined identifier: " << ident << endl;
      delete(find_ident->second);
      tbl->erase(ident);
    }
    (*tbl)[ident] = d;
  }

  descriptor* access_symtbl(string ident) {
    for (symbol_table_list::iterator i = symtbl.begin(); i != symtbl.end(); ++i) {
      symbol_table::iterator find_ident;
      if ((find_ident = (*i)->find(ident)) != (*i)->end()) return find_ident->second;
    }
    return NULL;
  }

private:
  typedef map<string, descriptor* > symbol_table;
  typedef list<symbol_table* > symbol_table_list;
  symbol_table_list symtbl;
  
};

