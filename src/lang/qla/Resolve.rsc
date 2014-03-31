module lang::qla::Resolve

import lang::qla::AST;
import Message;
import IO;
import ParseTree;
import List;
import Set;

alias Use = map[loc use, set[loc] defs];
alias Def = map[loc def, set[Type] types];

alias Refs = tuple[Use use, Def def];

alias Labels = map[str label, set[loc] questions];
alias Info = tuple[Refs refs, Labels labels];

Info resolve(Form f) {
  // Lazy because of declare after use.
  map[loc, set[loc]()] useLazy = ();
  Def def = ();
  Labels labels = ();
  
  map[Id, set[loc]] env = ();	
  
  // Return a function that looks up declaration of `n` in defs when called.
  set[loc]() lookup(Id n) 
    = set[loc]() { return env[n]? ? env[n] : {}; };


  void addUse(loc l, Id name) {
    useLazy[l] = lookup(name);
  }
  
  void addLabel(str label, loc l) {
    if (!labels[label]?) labels[label] = {};
    labels[label] += {l};
  }
  
  void addDef(Id n, loc q, Type t) {
    if (!env[n]?) env[n] = {};
    if (!def[q]?) def[q] = {};
    env[n] += {q};
    def[q] += {t};
  }
  
  visit (f) {
    case var(x): addUse(x@location, x); 
    case question(l, x, t): {
      addLabel(l, x@location);
      addDef(x, x@location, t);
    }
    case question(l, x, t, e): {
      addLabel(l, x@location); 
      addDef(x, x@location, t);
    }
  }
  
  // Force the closures in `use` to resolve references.
  use = ( u: useLazy[u]() | u <- useLazy );
  
  return <<use, def>, labels>;
}

rel[loc,loc,str] computeXRef(Info i) 
  = { <u, d, "<l>"> | <u, d> <- i.refs.use, <l, d> <- i.labels }; 

map[loc, str] computeDocs(Info i) {
  docs = { <u, "<l>"> | <u, d>  <- i.refs.use, <l, d> <- i.labels };
  return ( k: intercalate("\n", toList(docs[k])) | k <- docs<0> );
}
  