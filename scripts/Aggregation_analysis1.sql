SELECT 
  a.id,                    
  a.number,              
  a.rep,                   
  r.road_name,            
  m.municipality_name,    
  a.postal_code           
FROM address a
JOIN road r ON a.road_id = r.road_id              
JOIN municipality m ON a.insee_code = m.insee_code 
WHERE m.municipality_name = 'Villeneuve-de-Berg'  
ORDER BY r.road_name, a.number;
