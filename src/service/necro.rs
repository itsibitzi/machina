struct Service {
    id: u64,
}

pub struct Necromancer {
    services: Service,
}

impl Necromancer {
    pub fn register_service(&mut self,  service: &Service) {
        unimplemented!();
    }
}
