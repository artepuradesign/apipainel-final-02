import { useState } from "react";
import { useSearchParams, Link } from "react-router-dom";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import WhatsAppButton from "@/components/WhatsAppButton";
import { Star, SlidersHorizontal, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet";

// Mock search results
const mockResults = [
  {
    id: 1,
    name: "Seminovo iPhone 12 Pro Max 128GB - Azul Pacífico",
    oldPrice: 4116.47,
    newPrice: 2699.00,
    installments: 12,
    installmentPrice: 224.92,
    condition: "Excelente",
    discount: 34,
    rating: 4,
    image: "https://images.unsplash.com/photo-1592286927505-1def25115558?w=300&h=300&fit=crop",
  },
  {
    id: 2,
    name: "Seminovo iPhone 13 Pro 256GB Grafite",
    oldPrice: 5057.65,
    newPrice: 3499.00,
    installments: 12,
    installmentPrice: 291.58,
    condition: "Excelente",
    discount: 31,
    rating: 5,
    image: "https://images.unsplash.com/photo-1632661674596-df8be59a8713?w=300&h=300&fit=crop",
  },
  {
    id: 3,
    name: "Seminovo iPhone 11 64GB Preto",
    oldPrice: 2499.00,
    newPrice: 1799.00,
    installments: 12,
    installmentPrice: 149.92,
    condition: "Muito Boa",
    discount: 28,
    rating: 4,
    image: "https://images.unsplash.com/photo-1591337676887-a217a6970a8a?w=300&h=300&fit=crop",
  },
  {
    id: 4,
    name: "Seminovo iPhone 14 128GB Azul",
    oldPrice: 5999.00,
    newPrice: 4299.00,
    installments: 12,
    installmentPrice: 358.25,
    condition: "Excelente",
    discount: 28,
    rating: 5,
    image: "https://images.unsplash.com/photo-1678685888221-cda773a3dcdb?w=300&h=300&fit=crop",
  },
];

const FilterContent = () => (
  <div className="space-y-6">
    <div>
      <h4 className="font-medium mb-3 text-sm">Condição</h4>
      <div className="space-y-2">
        {["Excelente", "Muito Boa", "Boa"].map((cond) => (
          <label key={cond} className="flex items-center gap-2 text-sm cursor-pointer">
            <input type="checkbox" className="rounded border-border" />
            <span className="text-muted-foreground">{cond}</span>
          </label>
        ))}
      </div>
    </div>
    <div>
      <h4 className="font-medium mb-3 text-sm">Preço</h4>
      <div className="space-y-2">
        {["Até R$ 1.500", "R$ 1.500 - R$ 3.000", "R$ 3.000 - R$ 5.000", "Acima de R$ 5.000"].map((range) => (
          <label key={range} className="flex items-center gap-2 text-sm cursor-pointer">
            <input type="checkbox" className="rounded border-border" />
            <span className="text-muted-foreground">{range}</span>
          </label>
        ))}
      </div>
    </div>
    <div>
      <h4 className="font-medium mb-3 text-sm">Capacidade</h4>
      <div className="space-y-2">
        {["64GB", "128GB", "256GB", "512GB", "1TB"].map((cap) => (
          <label key={cap} className="flex items-center gap-2 text-sm cursor-pointer">
            <input type="checkbox" className="rounded border-border" />
            <span className="text-muted-foreground">{cap}</span>
          </label>
        ))}
      </div>
    </div>
  </div>
);

const Busca = () => {
  const [searchParams] = useSearchParams();
  const query = searchParams.get("q") || searchParams.get("categoria") || "";
  const [isFilterOpen, setIsFilterOpen] = useState(false);

  const formatPrice = (price: number) => {
    return price.toLocaleString("pt-BR", {
      style: "currency",
      currency: "BRL",
    });
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />

      {/* Breadcrumb - Hidden on mobile */}
      <div className="bg-secondary py-2 md:py-3 hidden sm:block">
        <div className="container">
          <nav className="flex items-center gap-2 text-xs md:text-sm text-muted-foreground">
            <Link to="/" className="hover:text-foreground">Home</Link>
            <span>/</span>
            <span className="text-foreground">Busca: "{query}"</span>
          </nav>
        </div>
      </div>

      <main className="container py-4 md:py-8">
        <div className="flex flex-col lg:flex-row gap-6 md:gap-8">
          {/* Desktop Sidebar */}
          <aside className="hidden lg:block w-60 shrink-0">
            <div className="sticky top-24 bg-card rounded-lg border border-border p-4">
              <h3 className="font-semibold mb-4">Filtros</h3>
              <FilterContent />
            </div>
          </aside>

          <div className="flex-1">
            {/* Results Header */}
            <div className="flex items-center justify-between gap-3 mb-4 md:mb-6">
              <div className="min-w-0">
                <h1 className="text-lg md:text-2xl font-bold truncate">Resultados para "{query}"</h1>
                <p className="text-xs md:text-sm text-muted-foreground">{mockResults.length} produtos</p>
              </div>
              <div className="flex items-center gap-2">
                {/* Mobile Filter Button */}
                <Sheet open={isFilterOpen} onOpenChange={setIsFilterOpen}>
                  <SheetTrigger asChild>
                    <Button variant="outline" size="sm" className="lg:hidden">
                      <SlidersHorizontal className="w-4 h-4 mr-2" />
                      Filtros
                    </Button>
                  </SheetTrigger>
                  <SheetContent side="left" className="w-[280px]">
                    <SheetHeader>
                      <SheetTitle>Filtros</SheetTitle>
                    </SheetHeader>
                    <div className="mt-6">
                      <FilterContent />
                    </div>
                    <div className="mt-6 pt-4 border-t border-border">
                      <Button className="w-full" onClick={() => setIsFilterOpen(false)}>
                        Aplicar Filtros
                      </Button>
                    </div>
                  </SheetContent>
                </Sheet>

                <select className="px-2 md:px-4 py-2 border border-border rounded-lg bg-background text-xs md:text-sm">
                  <option>Relevância</option>
                  <option>Menor preço</option>
                  <option>Maior preço</option>
                </select>
              </div>
            </div>

            {/* Results Grid */}
            <div className="grid grid-cols-2 lg:grid-cols-3 gap-3 md:gap-6">
              {mockResults.map((product) => (
                <Link
                  key={product.id}
                  to={`/produto/${product.id}`}
                  className="bg-card rounded-lg p-3 md:p-4 border border-border hover:shadow-lg transition-shadow group"
                >
                  {/* Image */}
                  <div className="relative aspect-square rounded-lg mb-2 md:mb-4 overflow-hidden">
                    <img
                      src={product.image}
                      alt={product.name}
                      className="w-full h-full object-cover rounded-lg group-hover:scale-105 transition-transform duration-300"
                    />
                  </div>

                  {/* Tags */}
                  <div className="flex items-center gap-1 md:gap-2 mb-1 md:mb-2">
                    <span className="px-1.5 md:px-2 py-0.5 md:py-1 bg-primary text-primary-foreground text-[10px] md:text-xs font-medium rounded">
                      -{product.discount}%
                    </span>
                    <span className="text-[10px] md:text-xs text-muted-foreground truncate">{product.condition}</span>
                  </div>

                  {/* Name */}
                  <h3 className="text-xs md:text-sm font-medium text-foreground line-clamp-2 min-h-[2rem] md:min-h-[2.5rem] mb-1 md:mb-2">
                    {product.name}
                  </h3>

                  {/* Rating */}
                  <div className="flex items-center gap-0.5 mb-1 md:mb-2">
                    {[...Array(5)].map((_, i) => (
                      <Star
                        key={i}
                        className={`w-2.5 h-2.5 md:w-3 md:h-3 ${i < product.rating ? "fill-yellow-400 text-yellow-400" : "text-muted"}`}
                      />
                    ))}
                  </div>

                  {/* Price */}
                  <div className="space-y-0.5">
                    <p className="text-muted-foreground line-through text-[10px] md:text-sm">
                      {formatPrice(product.oldPrice)}
                    </p>
                    <p className="text-base md:text-xl font-bold text-foreground">
                      {formatPrice(product.newPrice)}
                    </p>
                    <p className="text-[10px] md:text-xs text-muted-foreground">
                      {product.installments}x de {formatPrice(product.installmentPrice)}
                    </p>
                  </div>
                </Link>
              ))}
            </div>
          </div>
        </div>
      </main>

      <Footer />
      <WhatsAppButton />
    </div>
  );
};

export default Busca;
