% Launch the model and app, arranged side-by-side.
model = 'LUPA_Array_Eqk_circuit_w_PTO_DC_link_v2';
open_system(model);
app = WEC_Sankey_App;
set_param(model, 'Location', [50 50 1200 700]);
app.UIFigure.Position = [700 300 800 1000];
