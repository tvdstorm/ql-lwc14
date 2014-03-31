module lang::qla::Load

import lang::qla::Parse;
import lang::qla::AST;
import ParseTree;

//lang::qla::AST::Form load(loc l) = implodeQL(parseQL(l).top);
//lang::qla::AST::Form load(str src) = implodeQL(parseQL(src).top);
//
//lang::qla::AST::Form implodeQL(lang::qla::QL::Form f) 
//  = implode(#lang::qla::AST::Form, f);
  
  
Form load(loc l) = implodeQL(parseQL(l));
Form load(str src) = implodeQL(parseQL(src));

Form implodeQL(Tree f) = implode(#Form, f);