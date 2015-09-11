function [out,tout] = loadandresamp(s,fb,SRATE)
    res = load(char(fb),s);
    [out,tout] = resampleparam(getfield(res,s),SRATE,0);
  end