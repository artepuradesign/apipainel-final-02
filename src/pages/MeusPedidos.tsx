import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { 
  Package, 
  Search, 
  Eye, 
  Clock, 
  CheckCircle, 
  Truck, 
  MapPin,
  ChevronRight 
} from "lucide-react";

interface Order {
  id: string;
  orderNumber: string;
  date: string;
  status: string;
  total: number;
  items: {
    name: string;
    quantity: number;
    price: number;
    image: string;
  }[];
}

const statusConfig: Record<string, { label: string; color: string; icon: React.ElementType }> = {
  pending_payment: { label: "Aguardando Pagamento", color: "bg-yellow-100 text-yellow-800", icon: Clock },
  pending_approval: { label: "Aguardando Aprovação", color: "bg-orange-100 text-orange-800", icon: Clock },
  payment_approved: { label: "Pagamento Aprovado", color: "bg-green-100 text-green-800", icon: CheckCircle },
  in_preparation: { label: "Em Preparação", color: "bg-blue-100 text-blue-800", icon: Package },
  shipped: { label: "Enviado", color: "bg-purple-100 text-purple-800", icon: Truck },
  in_transit: { label: "Em Rota", color: "bg-indigo-100 text-indigo-800", icon: MapPin },
  delivered: { label: "Entregue", color: "bg-green-100 text-green-800", icon: CheckCircle },
  cancelled: { label: "Cancelado", color: "bg-red-100 text-red-800", icon: Clock },
};

const MeusPedidos = () => {
  const [orders, setOrders] = useState<Order[]>([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [customerEmail, setCustomerEmail] = useState<string | null>(null);

  useEffect(() => {
    // Get customer email from localStorage
    const email = localStorage.getItem("customerEmail");
    setCustomerEmail(email);

    // Get orders from localStorage (mock data for now)
    const storedOrders = localStorage.getItem("customerOrders");
    if (storedOrders) {
      setOrders(JSON.parse(storedOrders));
    }
  }, []);

  const filteredOrders = orders.filter(order => 
    order.orderNumber.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const formatPrice = (price: number) => {
    return price.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />

      <main className="container py-4 md:py-8">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
          <div>
            <h1 className="text-2xl md:text-3xl font-bold">Meus Pedidos</h1>
            {customerEmail && (
              <p className="text-sm text-muted-foreground mt-1">
                Pedidos associados a: {customerEmail}
              </p>
            )}
          </div>
          <div className="relative w-full md:w-72">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <Input
              placeholder="Buscar por número do pedido"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
        </div>

        {orders.length === 0 ? (
          <Card>
            <CardContent className="py-16 text-center">
              <Package className="w-16 h-16 mx-auto text-muted-foreground mb-4" />
              <h2 className="text-xl font-semibold mb-2">Nenhum pedido encontrado</h2>
              <p className="text-muted-foreground mb-6">
                Você ainda não realizou nenhuma compra.
              </p>
              <Button asChild>
                <Link to="/">Começar a Comprar</Link>
              </Button>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-4">
            {filteredOrders.map((order) => {
              const status = statusConfig[order.status] || statusConfig.pending_payment;
              const StatusIcon = status.icon;
              
              return (
                <Card key={order.id} className="overflow-hidden">
                  <CardHeader className="p-4 md:p-6 bg-muted/30">
                    <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
                      <div className="flex flex-col md:flex-row md:items-center gap-2 md:gap-6">
                        <div>
                          <p className="text-xs text-muted-foreground">Número do pedido</p>
                          <p className="font-bold text-lg">#{order.orderNumber}</p>
                        </div>
                        <div className="hidden md:block h-8 w-px bg-border" />
                        <div>
                          <p className="text-xs text-muted-foreground">Data</p>
                          <p className="font-medium">{order.date}</p>
                        </div>
                      </div>
                      <Badge className={`${status.color} flex items-center gap-1 w-fit`}>
                        <StatusIcon className="w-3 h-3" />
                        {status.label}
                      </Badge>
                    </div>
                  </CardHeader>
                  <CardContent className="p-4 md:p-6">
                    <div className="space-y-4">
                      {order.items.map((item, idx) => (
                        <div key={idx} className="flex items-center gap-4">
                          <img 
                            src={item.image} 
                            alt={item.name}
                            className="w-16 h-16 object-cover rounded-lg"
                          />
                          <div className="flex-1 min-w-0">
                            <p className="font-medium truncate">{item.name}</p>
                            <p className="text-sm text-muted-foreground">
                              Qtd: {item.quantity} • {formatPrice(item.price)}
                            </p>
                          </div>
                        </div>
                      ))}
                    </div>
                    
                    <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mt-6 pt-4 border-t">
                      <div>
                        <p className="text-sm text-muted-foreground">Total do pedido</p>
                        <p className="text-xl font-bold">{formatPrice(order.total)}</p>
                      </div>
                      <Button asChild variant="outline">
                        <Link to={`/pedido/${order.orderNumber}`}>
                          <Eye className="w-4 h-4 mr-2" />
                          Ver Detalhes
                          <ChevronRight className="w-4 h-4 ml-1" />
                        </Link>
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              );
            })}
          </div>
        )}
      </main>

      <Footer />
    </div>
  );
};

export default MeusPedidos;
