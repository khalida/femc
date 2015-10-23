%% Test lossPfem by doing some simple numerical examples:

t_test = ones(10,1);
y_test = ones(10,1);
parameters = [1, 1, 1, 0];

Pfem1 = lossPfem(t_test, y_test, parameters);